/*
Copyright (c) 2013 Up2Go International LLC
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products 
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/**
 *  Selectable Table row
 */
public class SObjectRow implements Comparable {
    
    //Variable properties
    public SObject delegate { get; set; }
    public Boolean isSelected { get; set; }
    public Boolean isChanged { get; set; }
    public Integer sortOrder { get; set; }
    public String docType { get; set; }
    
    //SObjectRow class constructor
    public SObjectRow(SObject delegate, Boolean isSelected) {
        this.delegate = delegate;
        this.isSelected = isSelected;
        this.isChanged = false;
    }
    
    //exception template instance
    public Exception_Template__c eTemplate {get;set;}
    public CPQ_Contract_Exception__c cException { get; set; }
    
    /**
     * @description: row constructor for cpq contract exceptions
     * 
     * @revision log: 05/23/2019 - Created - Victor Hanson - CR-20181019-12685
     **/
    public SObjectRow(Exception_Template__c eTemplate, Boolean isSelected, Integer sortOrder) {
        this.eTemplate = eTemplate;
        this.isSelected = isSelected;
        this.sortOrder = sortOrder;
    }
    
    /**
     * @description: row constructor for cpq contract exceptions w/template
     * 
     * @revision log: 05/23/2019 - Created - Victor Hanson - CR-20181019-12685
     **/
    public SObjectRow(CPQ_Contract_Exception__c cException, Exception_Template__c eTemplate, Boolean isSelected, Integer sortOrder) {
        this.cException = cException;
        this.eTemplate = eTemplate;
        this.isSelected = isSelected;
        this.sortOrder = sortOrder;
    }
    
    /**
     * @description: get the cpq contract exception and update he template/order fields
     * 
     * @revision log: 05/23/2019 - Created - Victor Hanson - CR-20181019-12685
     **/
    public CPQ_Contract_Exception__c getContractException() {
        if (cException == null) cException = new CPQ_Contract_Exception__c(Exception_Template__c = eTemplate.Id);
        cException.Order__c = this.sortOrder;
        return cException;
    }
    
    // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
        SObjectRow compareToRow = (SObjectRow)compareTo;
        if (sortOrder == compareToRow.sortOrder) return 0;
        if (sortOrder > compareToRow.sortOrder) return 1;
        return -1;        
    }
}