/**
*  Description     :  This class is for printing differnt types of star pattern.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  02/01/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public with sharing class PatternPrinting {
    
    /**
    * 
    *   @description    :   In this method print right triangle star pattern. 
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void starRightTrianglePattern(){
        String star = '';
        for(Integer i = 1; i <= 5; i++){
            for(Integer j = 1;j <= i; j++){
                star = '*' + star;
            }
        	System.debug(star);
            star = '';
        } 
    }

    /**
    * 
    *   @description    :   In this method print left triangle star pattern. 
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void starLeftTrianglePattern(){
        String star='';
        String space='';
        for(Integer i = 1;i <= 5; i++){
            for(Integer j = 1;j <= 5-i; j++){
                space = '_' + space;
            }
            for(Integer j = 1;j <= i; j++){
                star = '*' + star;
            }
        	System.debug(space + star);
            star = '';
            space = '';
        } 
    }

    /**
    * 
    *   @description    :   In this method print downward triangle star pattern. 
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void starDownwardTrianglePattern(){
        String star='';
        for(Integer i = 1;i <= 5; i++){
            for(Integer j = i;j <= 5; j++){
                star = '*' + star;
            }
        	System.debug(star);
            star = '';
        } 
    }

    /**
    * 
    *   @description    :   In this method print reversed pyramid star pattern. 
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void starReversedPyramidPattern(){
        String star='';
        String space='';
        for(Integer i = 1;i <= 5; i++){
            for(Integer j = 1;j < i; j++){
                space = '_' + space;
            }
            for(Integer j = i;j <= 5; j++){
                star = ' * ' + star;
            }
        	System.debug(space + star);
            star = '';
            space = '';
        } 
    }

    /**
    * 
    *   @description    :   In this method print right pascal triangle star pattern. 
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void starRightPascalTrianglePattern(){
        String star='';
        for(Integer i = 1;i <= 5; i++){
            for(Integer j = 1;j <= i; j++){
                star = '*' + star;
            }
        	System.debug(star);
            star = '';
        }
        for(Integer i = 1; i < 5; i++){

            for (Integer j = i; j < 5; j++) {
                star = '*' + star;
            }
            System.debug(star);
            star = '';
        } 
    }

    /**
    * 
    *   @description    :   In this method print sandglass star pattern. 
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void starSandglassPattern(){
        String space = '';
        String star = '';
        for(Integer i = 1;i <= 5; i++){
            for(Integer j = 1; j < i; j++){
                space = '_' + space;
            }
            for(Integer j = i;j <= 5; j++){
                star = ' * ' + star;
            }
        	System.debug(space + star);
            star = '';
            space = '';
        }
        for(Integer i = 1; i <= 5; i++){
            for (Integer j = i; j <= 5; j++) {
                space = '_' + space;
            }
            for (Integer j = 1; j <= i; j++) {
                star = ' * ' + star;
            }
            System.debug(space + star);
            star = '';
            space = '';
        } 
    }

    /**
    * 
    *   @description    :   In this method print left pascal triangle star pattern. 
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void starLeftPascalTrianglePattern(){
        String star = '';
        String space = '';
        for(Integer i = 1;i <= 5; i++){
            for (Integer j = i; j < 5; j++) {
                space = '_' + space;
            }
            for(Integer j = 1;j <= i; j++){
                star = '*' + star;
            }
        	System.debug(space + star);
            star = '';
            space = '';
        }
        for(Integer i = 1; i < 5; i++){
            for (Integer j = 1; j <= i; j++) {
                space = '_' + space;
            }
            for (Integer j = i; j < 5; j++) {
                star = '*' + star;
            }
            System.debug(space + star);
            star = '';
            space = '';
        } 
    }

    /**
    * 
    *   @description    :   In this method print number triangle star pattern. 
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void starNumberTrianglePattern(){

        Integer n = 7;
        for(Integer i = 1;i <= n; i++){
            String space = '';
            String result='';
            Integer num = i;
            for(Integer j = 1;j < i;j++){
                space = '_ '+ space;
            }
            for (Integer j = i; j <= (n*2)-i; j++) {
                result = result + ' ' + num;
                num++;
            }
            System.debug(space + result);
        }
        for(Integer i = 0;i < n; i++){
            String space = '';
            String result='';
            Integer num = n-i;
            for(Integer j = i;j < n-1;j++){
                space = '_ '+ space;
            }
            for (Integer j = n-i; j <= n+i; j++) {
                result = result +' '+ num;
                num++;
            }
            System.debug(space + result);
        }
    }

}