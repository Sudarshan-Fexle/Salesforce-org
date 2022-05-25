/**
*  Description     :  This is my first apex class.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  29/01/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public class MyFirstApexClass {
    

    public static Decimal firstNumber=8.2;
    public static Decimal secondNumber=10.2;
    public static Decimal result;

    /**
    * 
    *   @description    :   Sum of two numbers.
    *
    *   @args           :   No arguments
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 29/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void sumOfNumber(){
        result=firstNumber+secondNumber;
        System.debug('sum: '+result);
    }

    /**
    * 
    *   @description    :   this method return decimal value of the performed operations.
    *
    *   @args           :   decimal,decimal,string.
    *
    *   @return         :   decimal
    *
    *   @revision Log   :   V1.1 - Created  - 29/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static Decimal resultOfOperator(Decimal first,Decimal second,String oprator){
         if(String.isNotBlank(oprator) && (first != null || second !=null)){
            if(oprator == '+'){
                if (first !=null && second == null) {
                    return first;
                }else if(first ==null && second != null){
                    return second;
                }else{
                    return (first+second);
                }
            }else if(oprator=='-'){
                if (first !=null && second == null) {
                    return first;
                }else if(first ==null && second != null){
                    return second;
                }else{
                    return (first-second);
                }
            }else if(oprator=='*'){
                if (first !=null && second == null) {
                    return first;
                }else if(first ==null && second != null){
                    return second;
                }else{
                    return (first*second);
                }
            }else if(oprator=='/'){
                if (first !=null && second == null) {
                    return first;
                }else if(first ==null && second != null){
                    return second;
                }else{
                    return (first/second);
                }
            }else{
                return null;
            }
        }else{
            return null;
        }
    } 
}