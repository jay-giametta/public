/*
 * Name    :	FileSorter.java
 * Purpose :	Read files from a given source directory, sort the files,
 *              rename the files, place files in a given target directory
 * Dependencies:JpegFilter.java,JpegPhoto.java,Record.java
 * Author  :	Joseph Giametta
 * Date    :	20101011
-----------------------------------------------------------------------------*/

import java.io.*;
import java.util.*;
import java.text.*;

public class CameraSort
{
    private File targetDir, sourceDir;
    private String[] sourceFiles;
    private Record[] album;
    private String preName;

    //Returns the number of files in the source directory
    public int getAlbumSize()
    {
        return sourceFiles.length;
    }

    //Sets the source directory and stores a list of files within it
    public void setSource(File sourceDir)
    {
        this.sourceDir = sourceDir;

        //Save the list of jpeg files in the directory
        sourceFiles = sourceDir.list(new JpegFilter());
    }

    //Returns the name of the source directory
    public String sourceDirtoString()
    {
        return sourceDir.toString();
    }

    //Sets the target directory
    public void setTarget(File targetDir)
    {
        this.targetDir = targetDir;
    }

    //Returns the name of the target directory
    public String targetDirToString()
    {
        return targetDir.toString();
    }

    //Used by the sort method, but unseen by the outside class
    //Preps files for sorting
    private void setAlbum()
    {
        //Set record array size to number of files;
        album = new Record[sourceFiles.length];

        //Read in the name and date of the files
        for (int i=0; i < sourceFiles.length; i++)
        {
            JpegPhoto photo = new JpegPhoto();
            photo.setName(sourceDir.getPath() + "\\" + sourceFiles[i]);

            album[i] = new Record(photo.getDate(),sourceFiles[i]);
        }

    }

    //Sort the contents of the album array
    public void sort()
    {
        setAlbum();
        Arrays.sort(album);
    }

    //Get the prefix for new file names
    public void setPreName(String preName)
    {
        this.preName = preName;
    }

    //Returns the prefix used for new file names
    public String getPreName()
    {
        return preName;
    }

    //Moves sorted files from sourceDir to targetDir using the naming
    //convention preNamexxxx
    public void moveFiles()
    {
        //Format the file names
        final DecimalFormat numFormat = new DecimalFormat("0000");

        //Rename each file then move it to the target directory
        for (int i=0; i < album.length; i++)
        {
            String newName = preName + numFormat.format(i);

            File oldFile = new File(sourceDir.toString() + "\\" + album[i].getName());
            oldFile.renameTo(new File(targetDir.toString() + "\\"
                                    + newName + ".jpg"));

        }
    }



}
