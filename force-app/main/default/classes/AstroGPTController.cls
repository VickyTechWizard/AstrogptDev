public class AstroGPTController {
    private static final String ENDPOINT = 'https://api.openai.com/v1/chat/completions';
    @AuraEnabled
    public static String getAstroData(String searchString){
        OpenAiKey__c config = OpenAiKey__c.getOrgDefaults();
        String apiKey = config.Key__c;
        String searchQueryEscaped = (searchString).trim();
        
        try{
            String systemPrompt = 'Act as a Astrologer who is known as ASTROGPT, you are specialized in astrology and Prediction with the complete'+ 
                'knowledge of Human Existance. You take Name, Place of Birth, Date of Birth from User and Make Generic or common Prediction by ther Query.'+
                ' You will Create Kundli and Answer according to that.';
            Map<String, Object> requestBodyMap = new Map<String, Object>{
                'model' => 'gpt-3.5-turbo',
                'messages' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'role' => 'system',
                        'content' => systemPrompt
                    },
                    new Map<String, Object>{
                        'role' => 'user',
                        'content' => 'USER QUERY: ' + searchQueryEscaped
                    }
                }
            };
			String reqBody = JSON.serialize(requestBodyMap);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(ENDPOINT);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + String.escapeSingleQuotes(apiKey).trim());
            // Setting timeout to max 120 seconds to get the whole response from Chat GPT Open API
            request.setTimeout(120000);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Set the body as a JSON object
            request.setBody(reqBody);
            
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200){
                String calloutresponse = response.getBody();
                if(String.isNotEmpty(calloutresponse)){
                	String responseContent = parseJSONResponse(calloutresponse);
                    return responseContent;
                }
                
            } else{
                System.debug('OpenAI Chat Completions Callout Failed with status code: ' + response.getStatusCode());
                System.debug('Error Message: ' + response.getBody());
            }
            
        } catch(Exception ex){
           System.debug(ex.getMessage()); 
        }
        return null;
    }
    
    public static string parseJSONResponse(String response){
        String content;
        Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        List<Object> choices = (List<Object>) deserializedResponse.get('choices');
        if (choices != null && !choices.isEmpty()) {
            Map<String, Object> choiceMap = (Map<String, Object>) choices[0];
            Map<String, Object> messageMap = (Map<String, Object>) choiceMap.get('message');
            content = (String) messageMap.get('content');
            //system.debug('content'+content);
        }
        return content;
    }

}