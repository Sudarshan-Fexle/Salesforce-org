/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=false)
global class ContactExtensionMock implements HttpCalloutMock {
/**
    Purpose         :   Mock class for test out the HTTP callout associated with ContactExtension apex class.
                
    Created By      :	Abhinav Sharma   
    
    Created Date    :	07/07/2016   
    
    Revision Log    :   v1.0 - Created - 07/07/2016 - Abhinav Sharma - CR-20150202-8631 - Code refactor CR

**/    
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('rMLnJfV5ehYJvFGFG7tt7GCYG10J3d/u1dxExFDDJLkau6AO+arlCgN0/xKtPaT61wK55HRD8ytJKCxPgyt9WgLDUd8zwfWfg' + 
                    'BHTSAH462xst4WCs8OxoF+y1eLpkPfg1iGTTHnKJKO2A4fShMam3D5Q0mfbh37wC2m362k6LDPvpcoOr0WcMol1dhIgkM5LZV3' + 
                    'N0nWwzJgtSEihiJ6Nsj1tvf5/zhwT6xXjZId7N1k24f0y7pvaKA6OwC2DP9XrMhv3biBVF5UaNIVPIdnBjrO9UiA/SDvpOlFg5rt' +
                    'j/Er2gQQRO5daE8y7240gggbyjckDMb3rDiUaREpX8/3ZEeAsmyJCeABUQGoWQ6iulcorQZH4Z4t1H314oN9V419Y7A1OU5oCRzpzV4' +
                    'jcThzUfimZoJCnInL0ZSPCkcw23tx47hkZjwpk8obakZ4l4SB0OGk8APZa/Cx6YM9zSd5ba0cyNl2GIU19ktbwPGuQsTqWLzZBDbEKi' + 
                    '4PbczVjdQeY2LGKq3ujfFwpB3SmTsZ3dl0XdnsRmKjjGpeLFFlFUSwHdp8SK1SEctOSDvviSryMX+csPV2vkii9tFRdpjDOwr+Pb8oQ2V' +
                    'Y2e+WdZDozVPKY4HXGKMCOAlxBfeMT4XVj+Po7p+5XMB1p+IIlyibWBTOK6fHxL8t1W2858zEJ+QiO0eE3qTpTkegW/vvxb7STST+D' +
                    '9VAR9fVFYPtzMpkt42mVORJ9At7zk/ZGf7KMuMTAx/wpZpMhGhQJiuE3jC/yopA8rKh3Vwyt6S3TkRpgwKBZDBTfV5h0kuJKl0UMlqT' +
                    '7qFhN/YwG9xUnsHZM5DMOJLjZ3QEuTOZthEDLBcRreFHKaoJXB+EemCTVEzeWoJajQInEpAFQieSSEEKsA3JWTQnESf3rgHhnYpqmot' +
                    'mMJbf8+n+UR73kHLGX7Z/zTvUbaMolPblUmFxTvUvar5UUOZbSwgknHvFwDCyeBTMEpX+y5IZvcgsTAt49V/uGVpSwC2ahRt2V6oSwW' +
                    'IobOCBGdXTMGtyVwSL1+8jPJ/xeZ15DoML+bfofWfz2f+4nYTpQ/SxipCw5a5D41kAerbGZvpKPdaCZBLNqT5eYOUceU+tm6uDKUdzbR' +
                    't9Ubud9ssTYvNyyZbvXf87GnFTs3qYmhK0FZwUPUJmix4FNxaiiv3OHrIifmNJnjpO8GYEN2h4TaADRohION1VUUMxGpPPnnvN1iLdG4' +
                    'ueM4Yi8BAwCe1Lrg9ONsthYYlKZyLtFCv/pVUdxzxoqVMRapJ7dW3JdEWAmfeBugqamV8DPX7R/4oQLuxlq5RSQbho95Q7GBNYPkG1' +
                    'zwVypjmF7pp4Pwv4qAchNGyT7jpU9jmVJ18MbrDu2kLtU0vjx6+/dkSRtcCMpPBDuLld9NjBYLv3LFy0u2m39yErBpErii9nGEXMd70P' +
                    'q5GDVCs1cFzqaacOb4JJmtkd+61HzsmrwSORxzvwCvT9IeGgxmnfzw0AwRg0vCNekswAzLLVOsm1iDDSpeq3GL8Yi1yBvLPLuTrE/2bpk' +
                    '7Pd/HGFnw8m7yleVSC/2Q3rj1Da9/EMsNF0u9jypoI06HCGsgnFOC4YOu3LEhkhU3/ouC7zCiF6rDDZc4ZsAESvMIyevC+NCKj3byZ' + 
                    'G4U/z57YQoo94hlMzmO9exzItRrWz+Na1y0cLZF6CXag0O/cLrgzZjgBP/HCmGE4+95JIK4H0vEe561PNwUqOLVQr+iIflDw7xU9jjBOy' +
                    'mx9eSMDrpSKgGyRreBa0iE2dTqWi7ivNT2t6WUVH8HjzlJpJ7M1j42wHerkRlMJQ9zVLFkOnZii7OoS83aBm4wD/Ew+YlmPflY3KtkDO' + 
                    'jBZHa5bSoGLuvO2xA5u1odXS7+WCzHLboKWvtVEphR5YHbYswiu4F05Rw8o5YQCCqBvJDorEhwXWBAXRg1gxBEOURiMkzKmPsm9VV+b' + 
                    'dv3XQn8N4dtBdVnBZw13tl1FXyq1WdyEJYRjHgaPh0ILCZ3uP2esTA0GEdU/2DLCTDlzFzL97LbfWRHRtLuK62dNCh1A8SDxAMgjxsQZ' + 
                    'dM+WkwuGal/KwPTB4VSKH6L4ab850kic60nqXjbiB4qIUSQy8idTiBujdMeQZ0Q8UF0sH2HUsxF/5GmQI8yY2c1QKEKwlNyug7s2j0U7t' +
                    'pt21tM1asfTtZc30QBIGqMPYMMZYOeIgJ1Ugh7vNOiXgszUdoop2GOPlXp4Ys/OcTPmphOZp62q2m63GjaG4cZ9k5lQql2YsJUsbwC7pe' +
                    'ArwCPoJun6vTJtf0HCZKPpR8S2WBSUc9sCJvM7Yfald7SK3q9HsCXBJNTOysWRg8OEXzvkWlPXi5TpEB2Dd0ukeWzXqW5twOBpEeaj/bKv' + 
                    'Z8Sr/nTOwG7bgNb3V2SRhRzZFm7yL1MMbdR88c8h6EwNBZGhI/qbnqApU03ILTk7UBmTQzE+m4NaXteTBJ1/QdjUzDrDHrWSHR0yN90qgg4U' + 
                    'lmdkbIACkIVV10BRirSvQLfXMVtZG2E6huGr7DETUAAucNkkyzU3ZSG3IWXEqoTM2tJ3VK7l8BULRY56oLGEHJEwCV2uGg7irgs2Sh5/9t' + 
                    'G/EjGP/jfJ3iWva9Y+gYTa9JUTVXpi5YMY1Fb8dj3JpDckTmgpeRFRS2bpV/fLwftbn9ijYEET0xmVwtkF/4tMkpfj6JKymF1WRzsobQ3t1Qc' + 
                    'wpZObGTARu+iGVZRTmctuaSA8zZChGR1lDx4UxV5NA1x1f0gBBRiQ0fe4T6zWgKqDXilPbYHdrAMUxcmoLrQW6p97uPZihK1irvGCpk40Fvz3' +
                    'MmOprqqHFrRRVfyaRFgRIg01nCOQ6H1iPKr8ElrMl27mgtNc5UOjkHaKmBV62C3qRPuPteG5QbdXiwX+8RD5YaWy8guOvylf015nDGQSDvKaLgD' + 
                    'Erx/RSiI98WAI1tF3/v5NMyRK6Zdwt1gvrWzQPaNFnGJ3p2TX1hYIhNs/3b9VTZYg3dzBdEOvhWbH1JIZEZFkbZvIfl9ZetnkyUOeXZJVIRLJg+J9' + 
                    'FYN1L0FX2dDLSaU2VtELSk7IbjPLtMejNQOkcNEO2F+fvBJbUl8SAOTdS5aoe7Q/9DxYfwV8qSd+9iW+mYEctBWsrsyxfA6vFaw0cin2CwYldMjcOfL' + 
                    'UNmbEWOaH1lSiI+py3qbTcn+ATiGmOJkw0UK1r2hB3UEUgCXHDrkKObFPpWXPtlSFTSSehTEf4eChlo523V9jE+WMhGQDflQjg3Rj7Hg5CFBXBHaZWe' + 
                    'Kov2xkEhZjDdykNpZKxl+aXd87bppunuZK3rzu953EOJeEjqq4yAaB7Ry2lp9PzwXSCGUuGqpG6v6SPrRwiVq8Nt/LPIw1jxI8KJk+fkO/O519RtIl+E' + 
                    'bfIPokpSFUyjh32mAV7NYLHRdgdT1c/aT3OklLm0FVvuaDfvhkkz/rYiM/UsCEA/kOAK1q+5VTCzicK5ZJYF+uUGLDBwvCaVQSNdqDtrYU8uGHO6RRY+f' + 
                    'x9gobezfitWnZT4iY+zf3kUE0db9ztqC3rv3nTVy57sL6j42l0eU/j5zuxqvvqKzfQKqJuo1incnis7JWRgoVOAnVA4WNAEYor4OB4nTGiIRqCE5WAE' + 
                    'mrW/9lpTiHo7QjFOwf5BlEzWi2W5fxpEEy6/qaFRl5tTN/yg6PJPBBM/0Ecpcdxt7UhnpeRv5OLunAx4Q9pjA63CVJwtWoeVJMf3/cD7dJ8ERvcrMIo4oi' + 
                    'nCGxz8XPude3v96QncBvt+JbUhMsCZj+uVCkLOzagYnBp25Rd012TRkIWwhQi6EYown6/v/ZRPv+BAGVYk1UtW80lV+nckAxI95Je/XcTxRmAwrg/y9N' + 
                    'lxb2Eb7SMor8JTqQuVphOIW+yyV+tNAvNts1pLKAWLo7nM=');
        res.setStatusCode(200);
        return res;
    }
}