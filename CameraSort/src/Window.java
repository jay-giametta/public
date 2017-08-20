/*
 * Name    :	Window.java
 * Purpose :	Display a window and drive user program using button clicks
 * Dependencies:FileSorter.java
 * Author  :	Joseph Giametta
 * Date    :	20101011
-----------------------------------------------------------------------------*/
/*Some code used from http://java.sun.com/docs/books/tutorial/uiswing/components/filechooser.html
  but heavily modified*/

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

public class Window extends JPanel
                      implements ActionListener
{
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	//Declare shared variables
    private JButton sourceButton, targButton, sortButton;
    private JTextArea log;
    private JFileChooser fc;
    private CameraSort pictureSorter;

    public Window()
    {
        super(new BorderLayout());

        //Initialize log
        log = new JTextArea(20,40);
        log.setMargin(new Insets(5,5,5,5));
        log.setEditable(false);
        JScrollPane logScrollPane = new JScrollPane(log);
        log.append("Please choose source and target directories, then click Sort.\n");

        //Initialize file chooser
        fc = new JFileChooser();
        fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);

        //Initialize file sorter
        pictureSorter = new CameraSort();

        //Initialize buttons
        sourceButton = new JButton("Source directory");
        sourceButton.addActionListener(this);

        targButton = new JButton("Target directory");
        targButton.addActionListener(this);
        targButton.setEnabled(false);

        sortButton = new JButton("Sort");
        sortButton.addActionListener(this);
        sortButton.setEnabled(false);

        //Create button panels
        JPanel topButPanel = new JPanel();
        topButPanel.add(sourceButton);
        topButPanel.add(targButton);

        JPanel botButPanel = new JPanel();
        botButPanel.add(sortButton);

        //Add the buttons and the log to the panel.
        add(topButPanel, BorderLayout.PAGE_START);
        add(logScrollPane, BorderLayout.CENTER);
        add(botButPanel, BorderLayout.PAGE_END);
    }

    //Determines actions handled on button clicks
    public void actionPerformed(ActionEvent event)
    {
        //Handle source button action.
        if (event.getSource() == sourceButton)
        {
            int returnVal = fc.showOpenDialog(Window.this);

            if (returnVal == JFileChooser.APPROVE_OPTION)
            {
                //Set the source directory for the file sorter
                pictureSorter.setSource(fc.getSelectedFile());

                //Make target button clickable(Ensures user follows intended program flow)
                targButton.setEnabled(true);

                //Log actions
                log.append("Source directory set to " + pictureSorter.sourceDirtoString() + ".\n");
                log.setCaretPosition(log.getDocument().getLength());
            }
        }

        //Handle target button action.
        else if (event.getSource() == targButton)
        {
            int returnVal = fc.showOpenDialog(Window.this);

            if (returnVal == JFileChooser.APPROVE_OPTION)
            {

                //Set the target directory for the file sorter
                pictureSorter.setTarget(fc.getSelectedFile());

                //Make sort button clickable
                sortButton.setEnabled(true);

                //Log actions
                log.append("Target directory set to " + pictureSorter.targetDirToString() + ".\n");
                log.setCaretPosition(log.getDocument().getLength());
            }
        }

        //Handle sort button action
        else if (event.getSource() == sortButton)
        {
            //Gray the buttons back out(Ensures nothing is changed while sorting/moving files)
            targButton.setEnabled(false);
            sortButton.setEnabled(false);
            sourceButton.setEnabled(false);

            //Sort pictures
            log.append("Sorting " + pictureSorter.getAlbumSize() + " files.\n");
            pictureSorter.sort();       
            log.append("Sort complete.\n");

            //Get and set prename for files
            log.append("Requesting naming information...\n");

            //Loop to avoid passing a null value from JOptionPane
            while(pictureSorter.getPreName() == null)
            {
                pictureSorter.setPreName(JOptionPane.showInputDialog(null,
                          "What is the naming prefix?",
                          "Enter a prefix",
                          JOptionPane.QUESTION_MESSAGE));

                if(pictureSorter.getPreName() == null)
                {
                    int leave = JOptionPane.showConfirmDialog(null,
                            "Would you like to exit the program?\n",
                            "Confirm exit",
                            JOptionPane.YES_NO_OPTION);

                    if(leave == JOptionPane.YES_OPTION)
                    {
                        System.exit(0);
                    }

                }
            }

            //Rename and move files from targetdir to sourcedir
            log.append("Moving files.\n");
            log.setCaretPosition(log.getDocument().getLength());
            pictureSorter.moveFiles();

            //Log job completion
            log.append("Job complete.\n");
            log.setCaretPosition(log.getDocument().getLength());

            //Allow for more entries
            sourceButton.setEnabled(true);
        }
    }

    //Set up the frame
    private static void showWindow()
    {
        //Create and set up the window.
        JFrame frame = new JFrame("JPEG Import");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        //Add content to the window.
        frame.add(new Window());

        //Display the window.
        frame.pack();
        frame.setVisible(true);
        frame.setLocationRelativeTo(null);
        
    }

    //Program driver
    public static void main(String[] args)
    {
        showWindow();
    }
}
