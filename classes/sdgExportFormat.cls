/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
/*V1.1 - Modified By - Mahendra Swarnkar - 02/04/2020 - CR-20200128-13664 - Added "without sharing" access modifier*/
public without sharing class sdgExportFormat {
    @Auraenabled
    public sdg__c sdg{get; set;}
    @Auraenabled
    public integer version{get;set;}
}