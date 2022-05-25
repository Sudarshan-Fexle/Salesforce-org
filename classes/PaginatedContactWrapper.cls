/*
	Purpose:		CR-2618 - This class is used to display more than 1000 rows on a visualforce page.
					It works by taking a large data set and dividing it in to sets of 1000.
					Each set is then displayed on the VF page.
	
	Created By:		Victor Hanson
	
	Created Date:	3/12/13
	
	Revision Log:	v1.0 - VRH - 3/12/13 - Created
*/
public with sharing class PaginatedContactWrapper {
	
	@TestVisible private List<SiteProfileSubscriptionUploadController.ContactWrapper> selectList=new List<SiteProfileSubscriptionUploadController.ContactWrapper>();
	private final Integer SUB_LIST_SIZE=1000;
	//Returns total numbers of items.
	public Integer getSize(){
		return selectList.size();
	}
	//Add SiteProfileSubscriptionUploadController.ContactWrapper.
	public void add(SiteProfileSubscriptionUploadController.ContactWrapper so){
			selectList.add(so);
	}
	//Gets SiteProfileSubscriptionUploadController.ContactWrapper at given index.
	public SiteProfileSubscriptionUploadController.ContactWrapper get(Integer index){
		if(index>-1 && index<getSize()){
			return selectList.get(index);
		}else{
			return null;
		}		
	}
	//Removes SiteProfileSubscriptionUploadController.ContactWrapper at given index
	public void remove(Integer index){
		if(index>-1 && index<getSize()){
			selectList.remove(index);
		}		
	}

	public void clear(){
		selectList.clear();
	}

	public List<SiteProfileSubscriptionUploadController.ContactWrapper> getSelectList(){
		return selectList;
	}

	//Gets Select Options for the given start and end index both are inclusive.
	public List<SiteProfileSubscriptionUploadController.ContactWrapper> getSubList(Integer startIndex,Integer endIndex){
		List<SiteProfileSubscriptionUploadController.ContactWrapper> subList=new List<SiteProfileSubscriptionUploadController.ContactWrapper>();
		if(startIndex>-1 && startIndex<selectList.size()&& endIndex>-1 && endIndex<selectList.size()&&startIndex<=endIndex){
			for(Integer i=startIndex;i<=endIndex;i++){
				subList.add(get(i));
			}
		}
		return subList;
	}
	//Gets Nth sub list by dividing the main list in sublists of SUB_LIST_SIZE(1000 elements).
	public List<SiteProfileSubscriptionUploadController.ContactWrapper>getNthSubList(Integer index){
		Integer subListCount=(Integer)(selectList.size()/SUB_LIST_SIZE);
		if(Math.mod(selectList.size(),SUB_LIST_SIZE)>0) subListCount++;
		if(index>=0 && index<=subListCount){
			Integer startIndex=index*SUB_LIST_SIZE;
			Integer endIndex=index*SUB_LIST_SIZE+(SUB_LIST_SIZE-1);
			if(endIndex>=selectList.size())endIndex=selectList.size()-1;
			return getSubList(startIndex,endIndex);
		}else{
			return new List<SiteProfileSubscriptionUploadController.ContactWrapper>();
		}
	}
	//Gets sublist for given index.

	public List<SiteProfileSubscriptionUploadController.ContactWrapper>get0(){
		return getNthSubList(0);
	}
	public List<SiteProfileSubscriptionUploadController.ContactWrapper>get1(){
		return getNthSubList(1);
	}
	public List<SiteProfileSubscriptionUploadController.ContactWrapper>get2(){
		return getNthSubList(2);
	}
	public List<SiteProfileSubscriptionUploadController.ContactWrapper>get3(){
		return getNthSubList(3);
	}
	public List<SiteProfileSubscriptionUploadController.ContactWrapper>get4(){
		return getNthSubList(4);
	}
	public List<SiteProfileSubscriptionUploadController.ContactWrapper>get5(){
		return getNthSubList(5);
	}
	public List<SiteProfileSubscriptionUploadController.ContactWrapper>get6(){
		return getNthSubList(6);
	}
	public List<SiteProfileSubscriptionUploadController.ContactWrapper>get7(){
		return getNthSubList(7);
	}
	public List<SiteProfileSubscriptionUploadController.ContactWrapper>get8(){
		return getNthSubList(8);
	}
	public List<SiteProfileSubscriptionUploadController.ContactWrapper>get9(){
		return getNthSubList(9);
	}
}