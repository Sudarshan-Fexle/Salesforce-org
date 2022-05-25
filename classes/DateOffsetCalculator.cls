public without sharing class DateOffsetCalculator 
{
    public static Integer returnOffsetValue(String specficDateDay, String thisDateDay) 
    {
        if(String.isBlank(specficDateDay) || String.isBlank(thisDateDay)) 
        {
            throw new customException('Please specify a non null day value for calculation.');
        }
        
        switch on thisDateDay 
        {
            when 'Monday'
            {
                switch on specficDateDay 
                {
                    when 'Monday'
                    {
                        return 0;
                    }
                    when 'Tuesday' 
                    {
                    	return 1;    
                    }
                    when 'Wednesday' 
                    {
                    	return 2;    
                    }
                    when 'Thursday' 
                    {
						return 3;                        
                    }
                    when 'Friday' 
                    {
                    	return 4;    
                    }
                    when 'Saturday' 
                    {
                    	return 5;    
                    }
                    when 'Sunday' 
                    {
                    	return 6;    
                    }
                    when else 
                    {
                        throw new customException('Please specify a valid day value for calculation.');
                    }
                }
            }
            when 'Tuesday' 
            {
                switch on specficDateDay 
                {
                    when 'Monday'
                    {
                        return -1;
                    }
                    when 'Tuesday' 
                    {
                        return 0;
                    }
                    when 'Wednesday' 
                    {
                        return 1;
                    }
                    when 'Thursday' 
                    {
                    	return 2;    
                    }
                    when 'Friday' 
                    {
                    	return 3;    
                    }
                    when 'Saturday' 
                    {
                    	return 4;    
                    }
                    when 'Sunday' 
                    {
                    	return 5;    
                    }
                    when else 
                    {
                        throw new customException('Please specify a valid day value for calculation.');
                    }
                }    
            }
            when 'Wednesday' 
            {
                switch on specficDateDay 
                {
                    when 'Monday'
                    {
                        return -2; 
                    }
                    when 'Tuesday' 
                    {
                        return -1;
                    }
                    when 'Wednesday' 
                    {
                        return 0;
                    }
                    when 'Thursday' 
                    {
                        return 1;    
                    }
                    when 'Friday' 
                    {
                        return 2;    
                    }
                    when 'Saturday' 
                    {
                        return 3;
                    }
                    when 'Sunday' 
                    {
                        return 4;
                    }
                    when else 
                    {
                        throw new customException('Please specify a valid day value for calculation.');
                    }
                }    
            }
            when 'Thursday' 
            {
                switch on specficDateDay 
                {
                    when 'Monday'
                    {
                        return -3;
                    }
                    when 'Tuesday' 
                    {
                        return -2;
                    }
                    when 'Wednesday' 
                    {
                        return -1;
                    }
                    when 'Thursday' 
                    {
                        return 0;
                    }
                    when 'Friday' 
                    {
                        return 1;
                    }
                    when 'Saturday' 
                    {
                        return 2;
                    }
                    when 'Sunday' 
                    {
                        return 3;
                    }
                    when else 
                    {
                        throw new customException('Please specify a valid day value for calculation.');
                    }
                }    
            }
            when 'Friday' 
            {
                switch on specficDateDay 
                {
                    when 'Monday'
                    {
                        return -4;
                    }
                    when 'Tuesday' 
                    {
                        return -3;
                    }
                    when 'Wednesday' 
                    {
                        return -2;
                    }
                    when 'Thursday' 
                    {
                        return -1;                        
                    }
                    when 'Friday' 
                    {
                        return 0;
                    }
                    when 'Saturday' 
                    {
                        return 1;
                    }
                    when 'Sunday' 
                    {
                        return 2;
                    }
                    when else 
                    {
                        throw new customException('Please specify a valid day value for calculation.');
                    }
                }    
            }
            when 'Saturday' 
            {
                switch on specficDateDay 
                {
                    when 'Monday'
                    {
                        return -5;
                    }
                    when 'Tuesday' 
                    {
                        return -4;
                    }
                    when 'Wednesday' 
                    {
                        return -3;
                    }
                    when 'Thursday' 
                    {
                        return -2;
                    }
                    when 'Friday' 
                    {
                        return -1;
                    }
                    when 'Saturday' 
                    {
                        return 0;
                    }
                    when 'Sunday' 
                    {
                        return 1;
                    }
                    when else 
                    {
                        throw new customException('Please specify a valid day value for calculation.');
                    }
                }    
            }
            when 'Sunday' 
            {
                switch on specficDateDay 
                {
                    when 'Monday'
                    {
                        return -6;
                    }
                    when 'Tuesday' 
                    {
                        return -5;
                    }
                    when 'Wednesday' 
                    {
                        return -4;
                    }
                    when 'Thursday' 
                    {
                        return -3;
                    }
                    when 'Friday' 
                    {
                        return -2;
                    }
                    when 'Saturday' 
                    {
                        return -1;
                    }
                    when 'Sunday' 
                    {
                        return 0;
                    }
                    when else 
                    {
                        throw new customException('Please specify a valid day value for calculation.');
                    }
                }                
            }
            when else 
            {
                throw new customException('Please specify a valid day value for calculation.');
            }
        }
    } 
    
    
}