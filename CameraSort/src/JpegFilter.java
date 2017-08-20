/*
 * Name    :	JpegFilter.java
 * Purpose :	A filename filter that rejects anything other than jpg or jpeg
 * Author  :	Joseph Giametta
 * Date    :	20101011
-----------------------------------------------------------------------------*/

import java.io.*;

public class JpegFilter implements FilenameFilter
{
    //Only accepts jpeg or jpg files
    public boolean accept(File dir, String name)
    {

        //Rejects folders
        if (new File(dir, name).isDirectory())
        {
           return false;
        }

        //Ensures JPEG and JPG are also accepted
        name = name.toLowerCase();

        if(name.endsWith(".jpeg") || name.endsWith(".jpg"))
            return true;

        //Reject anything else
        else return false;
    }
}