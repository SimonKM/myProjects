global class batchSurveyResponse implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT  Id, Image_Score__c, score_info__c,Code__c,Survey_Question__r.Question_Number__c, Response__c,FilteredSoap__c,Survey_Question__r.Name, SurveyTaker__c, Weighting__c,Survey_Question__r.Choices_Code__c,  Soap_Id__c, Survey_Question__c, Score__c,Survey_Response__c  FROM SurveyQuestionResponse__c where Survey_Response__c=false ';
            //and SurveyTaker__r.Survey__r.Active__c=True';
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<SurveyQuestionResponse__c> scope)
    {
         set<String> soapId=new set<String>();
		 set<Id> stknId=new set<Id>();
         map<String, List<SurveyTaker__c>> responses=new map<String, List<SurveyTaker__c>>();
		 map<Id, List<SurveyTaker__c>> mapSurvyTkr=new map<id, List<SurveyTaker__c>>();
		 list<SurveyTaker__c> updateST = new list<SurveyTaker__c>();
        list<SurveyQuestionResponse__c> update39 = new list<SurveyQuestionResponse__c>();
        list<SurveyQuestionResponse__c> sqs=new list<SurveyQuestionResponse__c>();
        map<Id,list<Survey_Question__c>> mapSurveyQuestion = new  map<Id,list<Survey_Question__c>>();
        map<string, decimal> question39Map = new map<string, decimal>();
        String question = ' ';
        String respons = '';        
        
         for(SurveyQuestionResponse__c svQR : scope)
         {
             String sop=String.valueOf(svQR.Soap_Id__c);
             soapId.add(svQR.FilteredSoap__c); 
             
         }
         for(SurveyTaker__c surveyTkn:[Select Id, Soap_Id__c,FilteredSoap__c,Account__c,Survey__c,Contact__c, Total_Responses__c from SurveyTaker__c where FilteredSoap__c in:soapId ])
         {
			  stknId.add(surveyTkn.Id);
             if(mapSurvyTkr.get(surveyTkn.Id)==null)
             {
                 mapSurvyTkr.put(surveyTkn.Id,new List<SurveyTaker__c>());
             } 
             mapSurvyTkr.get(surveyTkn.Id).add(surveyTkn);
             if(responses.get(surveyTkn.FilteredSoap__c)==null)
             {
                 responses.put(surveyTkn.FilteredSoap__c,new List<SurveyTaker__c>());
             }
             responses.get(surveyTkn.FilteredSoap__c).add(surveyTkn);
             
         }
        
     
       for(SurveyQuestionResponse__c sqr:[select Code__c,Response__c,Survey_Question__c, SurveyTaker__c , Survey_Question__r.Question_Number__c from SurveyQuestionResponse__c where FilteredSoap__c in: soapId AND Survey_Question__r.Question_Number__c != null])
       {
         String key = sqr.Survey_Question__r.Question_Number__c+'-'+sqr.SurveyTaker__c;
           question39Map.put(key, sqr.Code__c);
       }
        
         for(SurveyQuestionResponse__c svQR : scope)
         {
			
             String key = svQR.Survey_Question__r.Question_Number__c+ '-'+svQR.SurveyTaker__c;
         
             decimal cod=0;
             String respns='';
            if(question39Map.containsKey(key))
            {
                System.debug('quet 39 ==>'+question39Map.get(key));
               
                if(question39Map.get('Q39a'+ '-'+svQR.SurveyTaker__c)==1)
                {
                     System.debug('quet 39a ==>'+question39Map.get('Q39a'+ '-'+svQR.SurveyTaker__c));
               
                    cod =1;
                    respns='Restaurant';	
                }
                else if(question39Map.get('Q39a'+ '-'+svQR.SurveyTaker__c)==2 && question39Map.get('Q39biv'+ '-'+svQR.SurveyTaker__c)==1  && question39Map.get('Q39c'+ '-'+svQR.SurveyTaker__c)==2  )
                {
                     cod=2;
                    respns ='Low Energy Bar';
                    
                }
                else if(question39Map.get('Q39a'+ '-'+svQR.SurveyTaker__c)==2  && question39Map.get('Q39biv'+ '-'+svQR.SurveyTaker__c)==1 && question39Map.get('Q39c'+ '-'+svQR.SurveyTaker__c)==1   )
                {
                    cod=3;
                    respns = 'High Energy Bar';
                }
                else if(question39Map.get('Q39a'+ '-'+svQR.SurveyTaker__c)==2 && question39Map.get('Q39biv'+ '-'+svQR.SurveyTaker__c)==2  && question39Map.get('Q39c'+ '-'+svQR.SurveyTaker__c)==1    )
                {
                    cod=4; 
                    respns = 'Night Club';
                }
               
			}
            if(svQR.Survey_Question__r.Question_Number__c=='Q39')
            {
                if(cod>0)
                {
                    svQR.Code__c=cod;
                    svQR.Response__c = respns;
              	}	
                           
            }	
             
             
             if(responses.containsKey(svQR.FilteredSoap__c))
              {
                if(svQR.Survey_Question__r.Choices_Code__c!=null)
           		{  
                	Map<string,Map<string,string>> mapJsonCode = (Map<string, Map<String,string>>)JSON.deserialize(svQR.Survey_Question__r.Choices_Code__c, Map<string, Map<String,string>>.class);
    			   if(svQR.Response__c!=null)
                   {
                        for(String choices:mapJsonCode.keyset())
                        {
                            if(choices.contains(svQR.Response__c) && svQR.Response__c.replaceAll('\r','').trim() == choices.trim() )
                            { 
                                svQR.Code__c= decimal.valueOf(mapJsonCode.get(choices).get('code'));
                                
                            }   
                        }
                   }
                }
                  
                  
                 for(SurveyTaker__c svTkn:responses.get(svQR.FilteredSoap__c))
                 {
                     /*if(svQR.Code__c!=null)
                     {
                         svQR.Display__c = string.valueOf(svQR.Code__c);
                     }
                     else
                     {
                         svQR.Display__c = svQR.Response__c;
                     }*/
                     svQR.SurveyTaker__c = svTkn.Id;
                     svQR.Survey_Response__c = true;
                     svQR.Survey__c = svTkn.Survey__c;
                 }
               
              }
            
         }
       
        update scope;
        
    }  
    global void finish(Database.BatchableContext BC) 
    {
        //System.scheduleBatch(New batchSurveyResponse(),'Batch Schedule for survey responses - ' + DateTime.now().getTime(),10);
    }

}