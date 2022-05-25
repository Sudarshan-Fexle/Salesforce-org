/**
*  Description     :  This class is for uses of different methods in list.
*
*  Created By      :  Sudarshan singh
*
*  Created Date    :  02/02/2022
*
*  Revision Logs   :  V1.0 - Created - Sudarshan Singh 
*
**/
public with sharing class ListClass {
    
    /**
    * 
    *   @description    :   In this method describe uses of bydefault methods of list. 
    *
    *   @args           :   None
    *
    *   @return         :   void
    *
    *   @revision Log   :   V1.1 - Created  - 02/02/2022 - Sudarshan singh - Comment
    * 
    **/
    public static void listClassMethods(){
        //Initializing of list and store some values in it.
        List<String> listOfFruits= new List<String>{'apple','banana','grapes','mango','papaya'};

        //Adds an element to the end of the list.
        listOfFruits.add('coconut');
        System.debug(listOfFruits);

        //Inserts an element into the list at the specified index position.
        listOfFruits.add(5, 'orange');
        System.debug(listOfFruits);

        List<String> secondListOfFruits =new List<String>{'water melon','pineapple','guava'};
        //Adds all of the elements in the specified list to the list that calls the method. Both lists must be of the same type.
        secondListOfFruits.addAll(listOfFruits);
        System.debug(secondListOfFruits);

        Set<String> setOfFruits =new Set<String>{'water melon','pineapple','guava'};        
        //Add all of the elements in specified set to the list that calls the method. The set and the list must be of the same type.
        listOfFruits.addAll(setOfFruits);
        System.debug(listOfFruits);

        //Removes all elements from a list, consequently setting the list's length to zero.
        secondListOfFruits.clear();
        System.debug(secondListOfFruits);

        //Makes a duplicate copy of a list.
        List<String> cloneList = listOfFruits.clone();
        System.debug(cloneList);

        //Returns true if the list contains the specified element.
        Boolean resultOfContainsMethod = listOfFruits.contains('coconut');
        System.debug(resultOfContainsMethod);

        //Compares this list with the specified list and returns true if both lists are equal; otherwise, returns false.
        Boolean resultOfEqualsMethod = listOfFruits.equals(cloneList);
        System.debug(resultOfEqualsMethod);

        //Returns the list element stored at the specified index.
        String resultOfGetMethod = listOfFruits.get(1);
        System.debug(resultOfGetMethod);

        //Returns the hashcode corresponding to this list and its contents.
        Integer resultOfHashCodeMethod = listOfFruits.hashCode();
        System.debug(resultOfHashCodeMethod);

        //Returns the index of the first occurrence of the specified element in this list. If this list does not contain the element, returns -1.
        Integer resultOfIndexOfMethod = listOfFruits.indexOf('apple');
        System.debug(resultOfIndexOfMethod);

        //Returns true if the list has zero elements.
        Boolean resultOfIsEmptyMethod = listOfFruits.isEmpty();
        System.debug(resultOfIsEmptyMethod);

        //Removes the list element stored at the specified index, returning the element that was removed.
        listOfFruits.remove(2);
        System.debug(listOfFruits);

        //Sets the specified value for the element at the given index.
        listOfFruits.set(2, 'Coconut');
        System.debug(listOfFruits);

        //Returns the number of elements in the list.
        Integer sizeOfList = listOfFruits.size();
        System.debug(sizeOfList);

        //Sorts the items in the list in ascending order.
        listOfFruits.sort();
        System.debug(listOfFruits);

        //Returns the string representation of the list.
        String stringOfList = listOfFruits.toString();
        System.debug(stringOfList);
		
        
    }

}