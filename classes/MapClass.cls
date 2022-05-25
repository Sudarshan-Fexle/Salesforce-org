/**
*  Description     :  This class is for uses of different methods in map.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  02/02/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public with sharing class MapClass {
    
    /**
    * 
    *   @description    :   In this method describe uses of bydefault methods of map.  
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/02/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void mapClassMethods(){

        //Initializing of set and store some values in it.
        Map<Integer,String> mapOfCountries = new Map<Integer,String>{1 => 'Afghanistan', 2 => 'Albania', 3 => 'Algeria', 4 => 'Andorra', 5 => 'Angola'};
        
        //Makes a duplicate copy of the map.
        Map<Integer,String> cloneMap = mapOfCountries.clone();
        System.debug(cloneMap);

        //Removes all of the key-value mappings from the map.
        cloneMap.clear();
        System.debug(cloneMap);

        //Returns true if the map contains a mapping for the specified key.
        Boolean resultOfContainKeyMethod = mapOfCountries.containsKey(3);
        System.debug(resultOfContainKeyMethod);

        //Compares this map with the specified map and returns true if both maps are equal; otherwise, returns false.
        Boolean resultOfEqualsMethod = mapOfCountries.equals(cloneMap);
        System.debug(resultOfEqualsMethod);

        //Returns the value to which the specified key is mapped, or null if the map contains no value for this key.
        String resultOfGetMethod = mapOfCountries.get(3);
        System.debug(resultOfGetMethod);

        //Returns the hashcode corresponding to this map.
        Integer resultOfHashCodeMethod = mapOfCountries.hashCode();
        System.debug(resultOfHashCodeMethod);

        //Returns true if the map has zero key-value pairs.
        Boolean resultOfIsEmptyMethod = mapOfCountries.isEmpty();
        System.debug(resultOfIsEmptyMethod);

        //Returns a set that contains all of the keys in the map.
        Set<Integer> keyOfMap = mapOfCountries.keySet();
        System.debug(keyOfMap);

        //Associates the specified value with the specified key in the map.
        mapOfCountries.put(6,'Argentina');
        System.debug(mapOfCountries);

        //Copies all of the mappings from the specified map to the original map.
        mapOfCountries.putAll(cloneMap);
        System.debug(mapOfCountries);

        //Removes the mapping for the specified key from the map, if present, and returns the corresponding value.
        mapOfCountries.remove(2);
        System.debug(mapOfCountries);

        //Returns the number of key-value pairs in the map.
        Integer sizeOfMap = mapOfCountries.size();
        System.debug(sizeOfMap);

        //Returns the string representation of the map.
        String stringOfMap = mapOfCountries.toString();
        System.debug(stringOfMap);

        //Returns a list that contains all the values in the map.
        List<String> valuesOfMap = mapOfCountries.values();
        System.debug(valuesOfMap);

    }
}