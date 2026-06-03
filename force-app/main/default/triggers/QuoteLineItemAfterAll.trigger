trigger QuoteLineItemAfterAll on QuoteLineItem (after insert, after update) {

    // Exit if context is not After Insert/Update
    if (!(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))) {
        return;
    }

    // Ensure we have records to process
    if (Trigger.new.isEmpty()) {
        return;
    }

    // Get the QuoteId from the first QuoteLineItem (all will have the same QuoteId)
    Id quoteId = Trigger.new[0].QuoteId;

    // Exit if QuoteId is null
    if (quoteId == null) {
        return;
    }

    Quote relatedQuote;

    // Fetch the relevant Quote record once
    try {
        relatedQuote = [SELECT Id, StartDate FROM Quote WHERE Id = :quoteId LIMIT 1];
    } catch (Exception e) {
        System.debug('Exception during Quote retrieval: ' + e.getMessage());
        return;
    }

    // Exit if the Quote record is not found
    if (relatedQuote == null) {
        return;
    }

    // List to collect QuoteLineItems to update
    List<QuoteLineItem> lineItemsToUpdate = new List<QuoteLineItem>();

    // Query QuoteLineItems to make them writable
    List<QuoteLineItem> qliRecords = [SELECT Id, StartDate FROM QuoteLineItem WHERE Id IN :Trigger.newMap.keySet()];

    for (QuoteLineItem qli : qliRecords) {
        // Update StartDate only if it differs
        if (qli.StartDate != relatedQuote.StartDate) {
            qli.StartDate = relatedQuote.StartDate;
            lineItemsToUpdate.add(qli);
        }
    }

    try {
        // Execute StartDate Update Logic for Update
        if (!lineItemsToUpdate.isEmpty()) {
            update lineItemsToUpdate;
            System.debug('Successfully updated StartDate for QuoteLineItems.');
        }

       
    } catch (Exception e) {
        System.debug('Exception during StartDate update or service method execution: ' + e.getMessage());
    }
}