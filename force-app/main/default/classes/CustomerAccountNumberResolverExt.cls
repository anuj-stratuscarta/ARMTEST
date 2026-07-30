/**
 * Customer Management GET extensibility:
 * 1. Resolves Account Number to Salesforce ID (e.g. id=ACM-2026-00973)
 * 2. Adds Industry and Description fields to the response
 */
//global class CustomerAccountNumberResolverExt implements comms_apex_ext.ICustomerManagementGET {
global class CustomerAccountNumberResolverExt {

    private static final List<String> ACCOUNT_NUMBER_FIELDS = new List<String>{ 'AccountNumber'};

    // Resolves account number to Salesforce ID when id is not already a 15/18-char Account ID
    global static Map<String, Object> transformRequest(Map<String, Object> context) {
        if (context == null) return context;

        Object idObj = context.get('id');
        if (idObj == null || !(idObj instanceof String)) return context;

        String idValue = ((String) idObj).trim();
        if (idValue == '') return context;

        if ((idValue.length() == 15 || idValue.length() == 18) && idValue.startsWith('001')) {
            return context;
        }

        String resolvedId = resolveToAccountId(idValue);
        if (resolvedId == null) return context;

        context.put('id', resolvedId);
        context.put('resolvedAccountId', resolvedId);

        return context;
    }

    // Queries Account by configured fields (AccountNumber) via dynamic SOQL
    private static String resolveToAccountId(String identifier) {
        for (String fieldName : ACCOUNT_NUMBER_FIELDS) {
            try {
                String soql = 'SELECT Id FROM Account WHERE ' + fieldName + ' = :identifier LIMIT 1';
                List<Account> accounts = Database.query(soql);
                if (!accounts.isEmpty()) return accounts[0].Id;
            } catch (Exception e) { continue; }
        }
        return null;
    }

    global static Map<String, Boolean> configureDefaultValidations(Map<String, Object> defaultValidationConfiguration, Map<String, Object> context) {
        return new Map<String, Boolean>();
    }

    global static Map<String, Object> applyCustomValidations(Map<String, Object> context) {
        return null;
    }

    // Adds Industry/Description to GraphQL query; filters by resolvedId when lookup was done
    global static Map<String, Object> customiseGraphQLQuery(Map<String, Object> querySpec, Map<String, Object> context) {
        // IMPORTANT: Use a single node - multiple nodes with same path overwrite each other
        Map<String, Object> node = new Map<String, Object>{
            'path' => 'customerAccount',
            'addFields' => new List<String>{ 'Industry { value }', 'Description { value }' }
        };

        if (context != null && context.containsKey('resolvedAccountId')) {
            String resolvedId = (String) context.get('resolvedAccountId');
            node.put('addFilters', new Map<String, Object>{
                'clearExistingFilters' => true,
                'filterGraphQlSnippet' => '{ Id: { eq: "' + resolvedId + '" } }'
            });
        }

        return new Map<String, Object>{ 'nodes' => new List<Object>{ node } };
    }

    // Routes to list or single-record handler based on payload structure
    global static Map<String, Object> handlePostOperation(Map<String, Object> graphQLResult, Map<String, Object> tmfResponse, Map<String, Object> context) {
        if (graphQLResult == null || tmfResponse == null) return null;

        if (tmfResponse.containsKey('recordList')) {
            return handleListResponse(graphQLResult, tmfResponse);
        }
        return handleSingleResponse(graphQLResult, tmfResponse);
    }

    // Enriches single record with Industry and Description from GraphQL result
    private static Map<String, Object> handleSingleResponse(Map<String, Object> graphQLResult, Map<String, Object> tmfResponse) {
        String accountId = (String) tmfResponse.get('id');
        Map<String, Object> node = getNodeById(graphQLResult, accountId);
        if (node == null) return null;

        Map<String, Object> updatedPayload = new Map<String, Object>(tmfResponse);
        addFieldToRecord(updatedPayload, node, 'Industry', 'industry');
        addFieldToRecord(updatedPayload, node, 'Description', 'description');

        return new Map<String, Object>{
            'payloadOverwritten' => true,
            'updatedPayload' => updatedPayload
        };
    }

    // Enriches each record in recordList with Industry and Description
    private static Map<String, Object> handleListResponse(Map<String, Object> graphQLResult, Map<String, Object> tmfResponse) {
        List<Object> recordList = (List<Object>) tmfResponse.get('recordList');
        if (recordList == null || recordList.isEmpty()) return null;

        Map<String, Map<String, Object>> idToNode = buildNodeMap(graphQLResult);

        List<Object> updatedRecordList = new List<Object>();
        for (Object recordObj : recordList) {
            Map<String, Object> record = new Map<String, Object>((Map<String, Object>) recordObj);
            String accountId = (String) record.get('id');
            Map<String, Object> node = idToNode.get(accountId);

            if (node != null) {
                addFieldToRecord(record, node, 'Industry', 'industry');
                addFieldToRecord(record, node, 'Description', 'description');
            }

            updatedRecordList.add(record);
        }

        Map<String, Object> updatedPayload = new Map<String, Object>(tmfResponse);
        updatedPayload.put('recordList', updatedRecordList);

        return new Map<String, Object>{
            'payloadOverwritten' => true,
            'updatedPayload' => updatedPayload
        };
    }

    private static Map<String, Object> getNodeById(Map<String, Object> graphQLResult, String accountId) {
        Map<String, Map<String, Object>> nodeMap = buildNodeMap(graphQLResult);
        return nodeMap.get(accountId);
    }

    // Parses GraphQL structure: data.uiapi.query.customerAccount.edges -> id-to-node map
    private static Map<String, Map<String, Object>> buildNodeMap(Map<String, Object> graphQLResult) {
        Map<String, Map<String, Object>> idToNode = new Map<String, Map<String, Object>>();

        Map<String, Object> data = (Map<String, Object>) graphQLResult.get('data');
        Map<String, Object> uiapi = (data != null) ? (Map<String, Object>) data.get('uiapi') : null;
        if (uiapi == null) return idToNode;

        Map<String, Object> query = (Map<String, Object>) uiapi.get('query');
        if (query == null) return idToNode;

        Map<String, Object> customerAccount = (Map<String, Object>) query.get('customerAccount');
        if (customerAccount == null) return idToNode;

        List<Object> edges = (List<Object>) customerAccount.get('edges');
        if (edges == null) return idToNode;

        for (Object edgeObj : edges) {
            Map<String, Object> edge = (Map<String, Object>) edgeObj;
            Map<String, Object> node = (Map<String, Object>) edge.get('node');
            if (node != null) {
                idToNode.put((String) node.get('Id'), node);
            }
        }

        return idToNode;
    }

    // Extracts value from GraphQL field object (field.value pattern) and adds to record
    private static void addFieldToRecord(Map<String, Object> record, Map<String, Object> node, String graphQLFieldName, String outputFieldName) {
        Object field = node.get(graphQLFieldName);
        if (field instanceof Map<String, Object>) {
            Object value = ((Map<String, Object>) field).get('value');
            if (value != null) {
                record.put(outputFieldName, String.valueOf(value));
            }
        }
    }
}