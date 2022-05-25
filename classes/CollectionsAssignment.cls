/**
*  Description     :  This class is for declaration and implementation of different types of collection.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  31/01/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public class CollectionsAssignment {
    
    /**
    * 
    *   @description    :   In this method implementation of collections are perform using two ways :- 1. at the time of initializing, 2. using collection methods. 
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 31/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void staticValuePopulation(){
        
        //Values assign at the time of initializing 
        List<String> listOfFruits= new List<String>{'apple','banana','grapes','mango','papaya'};
        //Values assign using list collection methods. 
        listOfFruits.add('coconut ');
        listOfFruits.add('water melon');
        listOfFruits.add('orange');
        listOfFruits.add('pineapple');
        listOfFruits.add('guava');
        System.debug(listOfFruits);

        //Values assign at the time of initializing
        Set<String> setOfAnimals= new Set<String>{'lion','tiger','wolf','giraffe','zebra'};
        //Values assign using set collection methods. 
        setOfAnimals.add('fox');
        setOfAnimals.add('panther');
        setOfAnimals.add('rabbit');
        setOfAnimals.add('elephant');
        setOfAnimals.add('monkey');
        System.debug(setOfAnimals);

        //Values assign at the time of initializing
        Map<Integer,String> mapOfCountries = new Map<Integer,String>{1 => 'Afghanistan', 2 => 'Albania', 3 => 'Algeria', 4 => 'Andorra', 5 => 'Angola'};
        //Values assign using map collection methods. 
        mapOfCountries.put(6,'Argentina');
        mapOfCountries.put(7,'Armenia');
        mapOfCountries.put(8,'Australia');
        mapOfCountries.put(9,'Austria');
        mapOfCountries.put(10,'Azerbaijan');
        System.debug(mapOfCountries);
    }

    /**
    * 
    *   @description    :   In this method values are pass through arguments and by this the list, set and map are created.
    *
    *   @args           :   List<String>, Integer
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 31/01/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void dynamicValuesPopulation(List<String> collectionTypes, Integer totalValues){
        
        //Values that are stored in new list, set and map
        List<String> listOfFruits= new List<String>{'apple','banana','grapes','mango','papaya'};
        List<String> listOfAnimals= new List<String>{'lion','tiger','wolf','giraffe','zebra'};
        List<String> listOfCountries = new List<String>{'Afghanistan','Albania','Algeria','Andorra','Angola'};
        
        //Initializing of new list, set and map
        List<String> listOfNameOfFruits = new List<String>();
        Set<String> setOfNameOfAnimals = new Set<String>();
        Map<Integer,String> mapOfNameOfCountries = new Map<Integer,String>();

        //Loop for values that are present in the collectionTypes.
      	for(Integer valueOfList = 0; valueOfList < collectionTypes.size(); valueOfList++){
           String collectionName=collectionTypes[valueOfList];

           //Check if the List is present in the list of collectionType.
            if(collectionName.equalsIgnoreCase('List')){

                //Values are created in the list.
                for(Integer i = 0;i < totalValues; i++){
                    listOfNameOfFruits.add(listOfFruits[i]); 
                }
                System.debug('Name of Fruits :-' + listOfNameOfFruits);
            }

            //Check if the Set is present in the list of collectionType.
            if(collectionName.equalsIgnoreCase('Set')){

                //Values are created in the set.
                for(Integer i = 0;i < totalValues; i++){
                    setOfNameOfAnimals.add(listOfAnimals[i]);
                }
                
                System.debug('Name of Animals :-'+ setOfNameOfAnimals);
            }
            
            //Check if the Map is present in the list of collectionType.
            if(collectionName.equalsIgnoreCase('Map')){
                
                //Values are created in the map.
                for(Integer i = 0;i < totalValues; i++){
                    mapOfNameOfCountries.put(i,listOfCountries[i]);
                }
                System.debug('Name of Countries' + mapOfNameOfCountries);
            }
        }

    }
}