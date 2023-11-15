public class OrderStatus.standardValueSet {

    public class OrderInfo {
        @InvocableVariable(label='Order ID' required=true)
        public Id orderId;
    }

    @InvocableMethod(label='Send Order Fulfillment Info to NPS' description='Sends order fulfillment information to the NPS service')
    public static void sendOrderFulfillmentInfo(List<OrderInfo> ordersInfo) {
        List<Order> orders = [SELECT Id, OrderNumber, BillToContact.Email FROM Order WHERE Id IN :getOrderIds(ordersInfo)];
        for (Order order : orders) {
            sendToNPS(order);
        }
    }

    private static List<Id> getOrderIds(List<OrderInfo> ordersInfo) {
        List<Id> orderIds = new List<Id>();
        for (OrderInfo info : ordersInfo) {
            orderIds.add(info.orderId);
        }
        return orderIds;
    }

    // Method to make HTTP callout to NPS service
    private static void sendToNPS(Order order) {
        String endpoint = 'https://salesforce-coding-challenge.herokuapp.com'; 

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        String username = 'tmondo'; 
        String password = 'Noy84LRpYvMZuETB'; 
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);

        Map<String, Object> body = new Map<String, Object>();
        body.put('orderNumber', order.OrderNumber);
        body.put('email', order.BillToContact.Email);
        String jsonBody = JSON.serialize(body);
        req.setBody(jsonBody);

        try {
            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                System.debug('Success: ' + res.getBody());
            } else {
                System.debug('Error: ' + res.getStatusCode() + ' ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
}
