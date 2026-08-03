/**
 * Mutation payload customization POST extensibility handler for Customer Management.
 * Demonstrates how to dynamically add Account fields (Description, Industry) to the GraphQL mutation
 * by reading values from the request body in the context.
 * Used in functional tests to verify customiseMutationPayload hook works correctly.
 */
//public class MutationAddFieldsPostExt implements comms_apex_ext.ICustomerManagementPOST {
public class MutationAddFieldsPostExt {
    
    /**
     * Transforms request context before processing.
     * Returns null to use context as-is.
     */
    public Map<String, Object> transformRequest(Map<String, Object> context) {
        return null;
    }
    
    /**
     * Configures default validation settings.
     * Returns empty map to use all default validations without modification.
     * 
     * @param defaultValidationConfiguration Default validation configuration map
     * @param context Request context containing API details
     * @return Empty map indicating no validation modifications
     */
    public Map<String, Boolean> configureDefaultValidations(Map<String, Object> defaultValidationConfiguration, Map<String, Object> context) {
        return new Map<String, Boolean>();
    }
    
    /**
     * Customizes the GraphQL query used to fetch data.
     * Returns empty map to use default query without modifications.
     * 
     * @param graphQLAsMap GraphQL query as a map
     * @param context Request context containing API details
     * @return Empty map indicating no query modifications
     */
    public Map<String, Object> customiseGraphQLQuery(Map<String, Object> graphQLAsMap, Map<String, Object> context) {
        return new Map<String, Object>();
    }
    
    /**
     * Handles post-processing after the POST operation completes.
     * Returns null to test null handling.
     * 
     * @param graphQLQueryResultAsMap Result of the GraphQL query execution
     * @param constructedTMFResponse The constructed TMF response
     * @param context Request context containing API details
     * @return null
     */
    public Map<String, Object> handlePostOperation(Map<String, Object> graphQLQueryResultAsMap, Map<String, Object> constructedTMFResponse, Map<String, Object> context) {
        return null;
    }
    
    /**
     * Applies custom validations to the POST request.
     * Returns empty map indicating no custom validation errors.
     * 
     * @param context Request context containing API details and request body
     * @return Empty map indicating validation passed
     */
    public Map<String, Object> applyCustomValidations(Map<String, Object> context) {
        return new Map<String, Object>();
    }
    
    /**
     * Customizes the mutation payload before the GraphQL mutation is executed.
     * Reads Description and Industry from the request body in context and adds them
     * to the Account node at alias path "customerAccount".
     * 
     * @param request The mutation request payload
     * @param context Request context containing API details and request body
     * @return Map containing mutation transformation instructions with nodes array:
     *         - nodes[0]: Contains path='customerAccount' and addFields with Description and Industry
     */
    public Map<String, Object> customiseMutationPayload(Map<String, Object> request, Map<String, Object> context) {
        // Return mutation transformation instructions: add Account fields at alias path "customerAccount"
        Map<String, Object> nodes0 = new Map<String, Object>();
        nodes0.put('path', 'customerAccount');
        Map<String, Object> addFields = new Map<String, Object>();
        
        // Read Description and Industry from request body in context
        Map<String, Object> requestBody = (Map<String, Object>)context.get('requestBody');
        if (requestBody != null) {
            String description = (String)requestBody.get('description');
            String industry = (String)requestBody.get('industry');
            String accountNumber  = (String)requestBody.get('accountnumber');
            // Add Description to Account if present in request
            if (description != null) {
                addFields.put('Description', description);
            }
            // Add Industry to Account if present in request
            if (industry != null) {
                addFields.put('Industry', industry);
            }
            if (accountNumber != null) {
                addFields.put('AccountNumber', accountNumber);
            }
        }
        
        nodes0.put('addFields', addFields);

        // Build nodes array containing the transformation instructions
        List<Object> nodes = new List<Object>();
        nodes.add(nodes0);

        // Return result with nodes array
        Map<String, Object> result = new Map<String, Object>();
        result.put('nodes', nodes);
        return result;
    }
}