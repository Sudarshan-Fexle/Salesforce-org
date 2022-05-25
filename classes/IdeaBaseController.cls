public virtual class IdeaBaseController {
    private final static Blob KEY = EncodingUtil.base64Decode('9WVAaQl734oCfJBIFrH1czDwueCOvDpOAI+wzbUTDm4=');
    public final static String LoginUrl = Label.BeMindful_Site_Auth_Url;
    public IdeaUserHelper CurrentUser { get; set; }

    public string HomePageUrl {
        get {
            if(HomePageUrl == null) {
                if(Site.getSiteId() != null) {
                    HomePageUrl = '/myIdeas';
                } else {
                    //HomePageUrl = Page.IdeasHomePage.getUrl();
                }
            }
            return HomePageUrl;
        }
        set;
    }

    public string ViewUrl {
        get {
            if(ViewUrl == null) {
                if(Site.getSiteId() == null) {
                    ViewUrl = HomePageUrl.replace('/ideashomepage', '/IdeaView');
                } else {
                    ViewUrl = HomePageUrl + '/IdeaView';
                }
            }
            return ViewUrl;
        }
        set;
    }

    public IdeaWrapper MyVote {
      get {
         List<Advisory_Idea_Vote__c> myVotes = [SELECT Advisory_Idea__c FROM Advisory_Idea_Vote__c
            WHERE Voted_By__c = :CurrentUser.ContactId];
         if(myVotes.size() > 0) {
            Advisory_Idea__c idea = [SELECT Title__c, High_Level_Description__c, Id, Score__c, Comments_Count__c, CreatedDate,
                     (SELECT Voted_By__c FROM Advisory_Idea_Votes__r),
                     (SELECT Commented_By__c FROM Advisory_Idea_Comments__r)
                     FROM Advisory_Idea__c WHERE IsDeleted=false AND id = :myVotes.get(0).Advisory_Idea__c];
            return new IdeaWrapper(idea, CurrentUser.ContactId);
         } else {
            return null;
         }
      }
    }

	 public Boolean HasVoted {
      get {
         return MyVote != null;
      }
    }

    public virtual PageReference Load() {
        if(CurrentUser == null) {
            PageReference pageRef = new PageReference(LoginUrl);

            String Id = ApexPages.currentPage().getParameters().get('id');
            if (Id != null) {
            	pageRef.getParameters().put('id', Id);
            }

            pageRef.setRedirect(true);
            return pageRef;
        } else {
           String encrypted = ApexPages.currentPage().getParameters().get('u');
           if(encrypted != null && encrypted != '') {
             PageReference pageRef = new PageReference(HomePageUrl);

             String Id = ApexPages.currentPage().getParameters().get('id');
             if (Id != null) {
            	pageRef.getParameters().put('id', Id);
             }

             pageRef.setRedirect(true);
             return pageRef;
          }
        }

        return null;
    }

    public IdeaBaseController () {
        Cookie cookieUserInfo = ApexPages.currentPage().getCookies().get('userInfo');
        String encrypted = ApexPages.currentPage().getParameters().get('u');
        String secret;
        if(encrypted != null && encrypted != '') {
            secret = Decrypt(EncodingUtil.base64Decode(encrypted));
        } else {
            if (cookieUserInfo != null) {
                encrypted = cookieUserInfo.getValue();
                secret = Decrypt(EncodingUtil.base64Decode(encrypted));
            }
        }
        if (secret != null && secret.length() == 6) {
            CurrentUser = new IdeaUserHelper(secret);

            if(CurrentUser.isValid) {
                cookieUserInfo = new Cookie('userInfo', encrypted, null, 9000000, false);
                ApexPages.currentPage().setCookies(new Cookie[]{cookieUserInfo});
            }
        }

        System.debug('##CurrentUser: ' + CurrentUser);
    }

    public static String Decrypt(blob encryptedBlob) {
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', KEY, encryptedBlob);
        return decryptedData.toString();
    }

    public static String Encrypt(string secret) {
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', KEY, Blob.valueOf(secret));
        return EncodingUtil.base64Encode(encryptedData);
    }
}