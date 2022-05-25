public class BoardroomHeaderController {
    
    public with sharing class MenuController {
    public MenuController () {
        String[] menuOptions = new String[]{'Community Impact','Travel','Expenses','Other Options...' };
        this.FullOptions = new SelectOption[]{};
        for (String c: menuOptions) {
            this.FullOptions.add(new SelectOption(c,c));
        }
    }
        
    public SelectOption[] FullOptions { //this is where we're going to pull the list
        public get;
        private set;
    }
}
}