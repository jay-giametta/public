/*
 * Name    :	Record.java
 * Purpose :	Create a comparable class that holds a date and string. The class
 *              is comparable by date value.
 * Author  :	Joseph Giametta
 * Date    :	20101011
-----------------------------------------------------------------------------*/

import java.util.*;

class Record implements Comparable<Object>
{
    private String name;
    private Date date;

    //Require a date and name on record construction
    public Record(Date date, String name)
    {
        this.date = date;
        this.name = name;
    }

    //Returns the date value stored
    public Date getDate()
    {
        return date;
    }

    //Returns the name of the record
    public String getName()
    {
        return name;
    }

    //Make records able to be compared
    public int compareTo(Object anObject) throws ClassCastException
    {
        Record otherRecord = (Record)anObject;

        if(otherRecord.date != null)
            return this.date.compareTo(otherRecord.date);

        else
            return 0;
    }
}
