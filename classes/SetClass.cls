/**
*  Description     :  This class is for uses of different methods in set.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  02/02/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public with sharing class SetClass {

    /**
    * 
    *   @description    :   In this method describe uses of bydefault methods of set. 
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/02/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void setClassMethods(){

        //Initializing of set and store some values in it.
        Set<String> setOfAnimals = new Set<String>{'lion','tiger','wolf','giraffe','zebra'};

        //Adds an element to the set if it is not already present.
        setOfAnimals.add('fox');
        System.debug(setOfAnimals);

        List<String> listOfAnimals = new List<String>{'panther','rabbit','elephant'};
        //Adds all of the elements in the specified list to the set if they are not already present.
        setOfAnimals.addAll(listOfAnimals);
        System.debug(setOfAnimals);

        Set<String> secondSetOfAnimals = new Set<String>{'panther','rabbit','elephant'};
        //Adds all of the elements in the specified set to the set that calls the method if they are not already present.
        secondSetOfAnimals.addAll(setOfAnimals);
        System.debug(secondSetOfAnimals);

        //Removes all of the elements from the set.
        secondSetOfAnimals.clear();
        System.debug(secondSetOfAnimals);

        //Makes a duplicate copy of the set.
        Set<String> cloneSet = setOfAnimals.clone();
        System.debug(cloneSet);

        //Returns true if the set contains the specified element.
        Boolean resultOfContainsMethod = setOfAnimals.contains('panther');
        System.debug(resultOfContainsMethod);

        //Returns true if the set contains all of the elements in the specified list. The list must be of the same type as the set that calls the method.
        Boolean resultOfContainsAllListMethod = setOfAnimals.containsAll(listOfAnimals);
        System.debug(resultOfContainsAllListMethod);

        //Returns true if the set contains all of the elements in the specified set. The specified set must be of the same type as the original set that calls the method.
        Boolean resultOfContainsAllSetMethod = setOfAnimals.containsAll(secondSetOfAnimals);
        System.debug(resultOfContainsAllSetMethod);

        //Compares this set with the specified set and returns true if both sets are equal; otherwise, returns false.
        Boolean resultOfEqualsMethod = setOfAnimals.equals(cloneSet);
        System.debug(resultOfEqualsMethod);

        //Returns the hashcode corresponding to this set and its contents.
        Integer resultOfHashCodeMethod = setOfAnimals.hashCode();
        System.debug(resultOfHashCodeMethod);

        //Returns true if the set has zero elements.
        Boolean resultOfIsEmptyMethod = setOfAnimals.isEmpty();
        System.debug(resultOfIsEmptyMethod);

        //Removes the specified element from the set if it is present.
        setOfAnimals.remove('wolf');
        System.debug(setOfAnimals);

        //Removes the elements in the specified list from the set if they are present.
        setOfAnimals.removeAll(listOfAnimals);
        System.debug(setOfAnimals);

        //Removes the elements in the specified set from the original set if they are present.
        cloneSet.retainAll(secondSetOfAnimals);
        System.debug(cloneSet);

        //Retains only the elements in this set that are contained in the specified list.
        secondSetOfAnimals.retainAll(listOfAnimals);
        System.debug(secondSetOfAnimals);

        //Returns the number of elements in the set (its cardinality).
        Integer sizeOfSet = setOfAnimals.size();
        System.debug(sizeOfSet);

        //Returns the string representation of the set.
        String setToSTring = setOfAnimals.toString();
        System.debug(setOfAnimals);

    }
    
}