/*
 * Name    :	JpegPhoto.java
 * Purpose :	Takes in the name of a jpeg file, opens the file, read stors the
 *              exif date information
 * Dependencies:metadata-extractor-2.3.1.jar
 * Author  :	Joseph Giametta
 * Date    :	20101011
-----------------------------------------------------------------------------*/

import java.io.*;
import com.drew.imaging.jpeg.*;
import com.drew.metadata.*;
import com.drew.metadata.exif.*;
import java.util.*;

public class JpegPhoto
{
    private Metadata metadata;
    private Directory exifDirectory;
    private String name;
    private File currentFile;

    //Require filename for class construction
    public void setName(String name)
    {
        this.name = name;
        setFile();
    }

    //Return the name of the jpeg file
    public String getName()
    {
        return name;
    }

    //Opens the jpeg file
    private void setFile()
    {
        currentFile = new File(name);

        //Preps file for later metadata extraction
        try
        {
            metadata = JpegMetadataReader.readMetadata(currentFile);

        }catch(JpegProcessingException e)
        {
        }
        exifDirectory = metadata.getDirectory(ExifDirectory.class);

    }

    //Gets date from exif date information
    public java.util.Date getDate()
    {
        final long DEFAULT = 0;
        final int EXIF_DATE_CODE = 36867;

        Date date = new Date(DEFAULT);

        try
        {
            if(exifDirectory.containsTag(EXIF_DATE_CODE))
                date = exifDirectory.getDate(EXIF_DATE_CODE);

        }catch(MetadataException e)
        {
        }

        return date;
    }

}
