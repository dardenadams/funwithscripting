// Windows Forms app for installing software on remote machines:
// - Contains fixed list of programs you can install (common apps I used to have to install manually)
// - User selects an app and selects a domain PC from dropdowns, clicks install or uninstall
// - Performs check on destination PC registry to ensure program isn't already installed
// - PowerShell copies app from pre-defined DFS location to temp location on destination pc
// - WMIC executes install/uninstall from locally copied installer
// - PowerShell performs cleanup, removing installation files from temp location
// Setup/Maintenance:
// - Installers must be located in centralized DFS location or other UNC path
// - TXT files containing registry key values also must be stored in UNC path to test for pre-existing installation
// - Installers and reg keys must be kept up to date
// Version 3.0 new features:
// -Added Uninstaller button!!
// -Now gets all app names and registry keys from central location on DFS share
// -Small improvements to the status bar

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Management;
using System.IO;
using Microsoft.Win32;

namespace RemoteInstallerv2._0
{
    public partial class MainWindow : Form
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        public class ComboboxItem
        {
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
        }

        private void SelectLabel_Click(object sender, EventArgs e)
        {

        }

        private void RemoteInstaller_Load(object sender, EventArgs e)
        {

        }

        // Install method
        private void CallInstall_Click(object sender, EventArgs e)
        {
            // Establish values
            string target = TargetSelection.Text;
            string product = AppSelection.Text;
            string uncdir = @"\\my-domain.local\dfs\Programs\RemoteInstallerSW\";
            string source = uncdir + product + ".msi";
            string destination = @"\\" + target + @"\c$\temp\";
            string testdest = destination + product + ".msi";
            string package = @"C:\temp\" + product + ".msi";
            bool twostep = false;

            progressBar.Visible = true;
            progressBar.Minimum = 0;
            progressBar.Maximum = 5;
            progressBar.Value = 1;
            progressBar.Step = 1;

            // Assign value to twostep if we are using an installer that requires dependant files (nested installer directory).
            if (product.Equals("Adobe Reader"))
            {
                twostep = true;
            }
            else if (product.Equals("Silverlight"))
            {
                twostep = true;
            }

            // Make sure user has selected something other than the default text for target and product
            if (!target.Equals("(Select)"))
            {
                if (!product.Equals("(Select)"))
                {

                    // If a registry key exists for the product, then cancel entire install operation on assumption
                    // that the product already exists at the destination:

                    // Establish variables to contain the reg key as a whole, the Products reg path, the specific key value to be tested,
                    // and all the possible keys that might be chosen by the user based on product.
                    // Current reg keys are stored at the universal standard location on DFS.
                    RegistryKey regkey;
                    string regpath = @"SOFTWARE\Classes\Installer\Products\";
                    string testkey = null; //set as null until it is assigned to one of the following:
                    string flashreg = System.IO.File.ReadAllText(@"\\my-domain.local\dfs\programs\RemoteInstallerSW\Resources\Registry\Flash\CurrentFlashGUID.txt");
                    string readerreg = System.IO.File.ReadAllText(@"\\my-domain.local\dfs\programs\RemoteInstallerSW\Resources\Registry\Reader\CurrentReaderGUID.txt");
                    string chromereg = System.IO.File.ReadAllText(@"\\my-domain.local\dfs\programs\RemoteInstallerSW\Resources\Registry\GChrome\CurrentChromeGUID.txt");
                    string earthreg = System.IO.File.ReadAllText(@"\\my-domain.local\dfs\programs\RemoteInstallerSW\Resources\Registry\GEarthPro\CurrentEarthProGUID.txt");
                    string earthproreg = System.IO.File.ReadAllText(@"\\my-domain.local\dfs\programs\RemoteInstallerSW\Resources\Registry\GEarthPro\CurrentEarthProGUID.txt");
                    string javareg = System.IO.File.ReadAllText(@"\\my-domain.local\dfs\programs\RemoteInstallerSW\Resources\Registry\Java\CurrentJavaGUID.txt");
                    string silverreg = System.IO.File.ReadAllText(@"\\my-domain.local\dfs\programs\RemoteInstallerSW\Resources\Registry\Silverlight\CurrentSLGUID.txt");

                    // Assign value of testkey according to product selected by user
                    if (product.Equals("Adobe Flash"))
                    {
                        testkey = flashreg;
                    }
                    else if (product.Equals("Adobe Reader"))
                    {
                        testkey = readerreg;
                    }
                    else if (product.Equals("Google Chrome"))
                    {
                        testkey = chromereg;
                    }
                    else if (product.Equals("Google Earth"))
                    {
                        testkey = earthreg;
                    }
                    else if (product.Equals("Google Earth Pro"))
                    {
                        testkey = earthproreg;
                    }
                    else if (product.Equals("Java"))
                    {
                        testkey = javareg;
                    }
                    else if (product.Equals("Silverlight"))
                    {
                        testkey = silverreg;
                    }
                    // Assign value of regkey dependant upon target PC and selected product, defined above.
                    regkey = RegistryKey.OpenRemoteBaseKey(RegistryHive.LocalMachine, target).OpenSubKey(regpath + testkey);

                    // Progress bar step #1
                    progressBar.PerformStep();

                    // If regkey doesn't exist, it will turn up as null. Therefore, if it is NOT null we can assume the product already exists
                    // or was uninstalled incorrectly leaving the key behind. Else, proceed with the installation.
                    if (regkey != null)
                    {
                        MessageBox.Show("Product already exists or was uninstalled incorrectly (registry key exists).", "Unable to Install", MessageBoxButtons.OK);

                        // Reset progress bar
                        progressBar.Value = 0;
                    }
                    else
                    {
                        try
                        {
                            // Use PowerShell to copy files to destination because I'm too lazy to bother creating a method
                            // to do so in C#. NOTE: requires reference to System.Management.Automation.
                            // Fork for nested or un-nested installer source directories
                            if (twostep)
                            {
                                source = uncdir + product;
                                package = @"C:\temp\" + product + "\\" + product + ".msi";
                                testdest = destination + product + "\\" + product + ".msi";

                                // First testing path to make sure installer doesn't already exist.
                                if (!File.Exists(testdest))
                                {
                                    using (PowerShell PowershellInstance = PowerShell.Create())
                                    {
                                        PowershellInstance.AddCommand("Copy-Item");
                                        PowershellInstance.AddParameter("Path", source);
                                        PowershellInstance.AddParameter("Destination", destination);
                                        PowershellInstance.AddParameter("Recurse");

                                        PowershellInstance.Invoke();
                                    }
                                }

                            }
                            else
                            {
                                if (!File.Exists(testdest))
                                {
                                    using (PowerShell PowershellInstance = PowerShell.Create())
                                    {
                                        PowershellInstance.AddCommand("Copy-Item");
                                        PowershellInstance.AddParameter("Path", source);
                                        PowershellInstance.AddParameter("Destination", destination);

                                        PowershellInstance.Invoke();
                                    }
                                }
                            }

                            // Progress bar step #2
                            progressBar.PerformStep();
                        }
                        catch (Exception error1)
                        {
                            MessageBox.Show("Powershell error. Details: " + error1, "Error #1", MessageBoxButtons.OK);
                            
                            // Reset progress bar
                            progressBar.Value = 0;
                        }

                        try
                        {
                            // Progress bar step #3
                            progressBar.PerformStep();

                            // Get handle on Windows Management Class Win32_Product on the target PC then grab 'Install'
                            ManagementClass classInstance = new ManagementClass("\\\\" + target + "\\root\\CIMV2", "Win32_Product", null);
                            ManagementBaseObject inparams = classInstance.GetMethodParameters("Install");

                            // Define parameters of install
                            inparams["PackageLocation"] = package;
                            //inparams["Options"] = silent;

                            // Call 'Install' with specified parameters
                            ManagementBaseObject outParams = classInstance.InvokeMethod("Install", inparams, null);

                            // Variable to contain results of installation. Must cast outParams as string using ToString() method in order to use in test below.
                            string results = outParams["ReturnValue"].ToString();

                            // Use results variable (string version of outParams) to determine if install was a success (error 0) or failure.
                            if (results.Equals("0"))
                            {
                                MessageBox.Show(product + " has been successfully installed", "Installation Success", MessageBoxButtons.OK);
                            }
                            else
                            {
                                MessageBox.Show("Installation failed with Windows Installer error code: " + outParams["ReturnValue"], "Installation Error", MessageBoxButtons.OK);
                            }

                            // Progress bar step #4
                            progressBar.PerformStep();
                        }
                        catch (Exception error2)
                        {
                            MessageBox.Show("Install error, details: " + error2, "Error #2", MessageBoxButtons.OK);
                            
                            // Reset progress bar
                            progressBar.Value = 0;
                        }

                        try
                        {
                            // Use Powershell to remove installer after it has been used. Fork based on nested/un-nested installer.
                            if (twostep != false)
                            {
                                using (PowerShell PowershellInstance = PowerShell.Create())
                                {
                                    PowershellInstance.AddCommand("Remove-Item");
                                    PowershellInstance.AddParameter("Path", destination + product);
                                    PowershellInstance.AddParameter("Recurse");

                                    PowershellInstance.Invoke();
                                }
                            }
                            else
                            {
                                using (PowerShell PowershellInstance = PowerShell.Create())
                                {
                                    PowershellInstance.AddCommand("Remove-Item");
                                    PowershellInstance.AddParameter("Path", destination + product + ".msi");

                                    PowershellInstance.Invoke();
                                }
                            }

                            // Progress bar step #5
                            progressBar.PerformStep();
                        }
                        catch (Exception error3)
                        {
                            MessageBox.Show("Powershell Remove-Item error, details: " + error3, "Error #3", MessageBoxButtons.OK);

                            // Reset progress bar
                            progressBar.Value = 0;
                        }
                    }
                }

                // Results if no product is selected
                else
                {
                    MessageBox.Show("Please select a product from the drop down menu", "Error, missing selection", MessageBoxButtons.OK);

                    // Reset progress bar
                    progressBar.Value = 0;
                }
            }

            // Results if no target is selected
            else
            {
                MessageBox.Show("Please select a target PC from the drop down menu", "Error, missing selection", MessageBoxButtons.OK);
                
                // Reset progress bar
                progressBar.Value = 0;

            }
        }

        // Uninstall method
        private void CallUninstall_Click(object sender, EventArgs e)
        {

            // Initialize progress bar
            progressBar.Visible = true;
            progressBar.Minimum = 0;
            progressBar.Maximum = 5;
            progressBar.Value = 0;
            progressBar.Step = 1;

            // Variables for the target input, app selected input, and the final product (blank, obtain from DFS later)
            string target = TargetSelection.Text;
            string proinput = AppSelection.Text;
            string product = "";

            // Progress bar step #1
            progressBar.PerformStep();

            // Convert product input to exact product name from the resource file located on DFS
            // Sets the product string to equal the full product name necessary to identify a Win32_Product
            try
            {
                if (proinput.Equals("Adobe Reader"))
                {
                    product = System.IO.File.ReadAllText(@"\\my-domain.local\dfs\programs\RemoteInstallerSW\Resources\Registry\Reader\Version.txt");
                }
                else if (proinput.Equals("Adobe Flash"))
                {
                    product = System.IO.File.ReadAllText(@"\\my-domain.local\dfs\programs\RemoteInstallerSW\Resources\Registry\Flash\Version.txt");
                }
                else if (proinput.Equals("Java"))
                {
                    product = System.IO.File.ReadAllText(@"\\my-domain.local\dfs\programs\RemoteInstallerSW\Resources\Registry\Java\Version.txt");
                }
                else if (proinput.Equals("Silverlight"))
                {
                    product = "Microsoft Silverlight";
                }
                else
                {
                    product = proinput;
                }
            }
            catch (Exception error1)
            {
                MessageBox.Show("Error converting app selection to full app name. Details: " + error1, "Uninstall Error #1", MessageBoxButtons.OK);

                // Reset progress bar
                progressBar.Value = 0;
            }

            // Make sure user has selected something other than the default text for target and product
            if (!target.Equals("(Select)"))
            {

                if (!product.Equals("(Select)"))
                {

                    // Perform final check to uninstall or cancel uninstall
                    DialogResult proceed = MessageBox.Show("Proceed with uninstall of " + proinput + "?", "Uninstall " + proinput, MessageBoxButtons.OKCancel);
                    if (proceed.Equals(DialogResult.OK))
                    {
                        // Progress bar step #2
                        progressBar.PerformStep();

                        try
                        {
                            // Variable for status of app (found or not found on target). Default value must be true.
                            bool appexists = true;

                            // Variables for scope of search (machine target), query (product name), and options for enum
                            // to prevent baggage carrying over to next search (rewind false, return now).
                            ManagementScope scope = new ManagementScope("\\\\" + target + "\\root\\cimv2", null);
                            SelectQuery query = new SelectQuery("Win32_Product", "Name='" + product + "'");
                            EnumerationOptions enumops = new EnumerationOptions();

                            enumops.ReturnImmediately = true;
                            enumops.Rewindable = false;

                            // Create searcher to find app with above inputs
                            ManagementObjectSearcher searcher = new ManagementObjectSearcher(scope, query);

                            // List to hold any apps found by searcher (below)
                            List<ManagementObject> apps = new List<ManagementObject>();

                            // Progress bar step #3
                            progressBar.PerformStep();

                            // Searcher finds all instances (should be one or none) of desired app and adds to list
                            foreach (ManagementObject app in searcher.Get())
                            {
                                apps.Add(app);
                            }

                            // Progress bar step #4
                            progressBar.PerformStep();

                            // For each app found in the list apps, uninstall. If no apps are found then the value of appexists is set to false (default is true), which
                            // triggers a messagebox that indicates the app wasn't found.
                            if (apps.Any())
                            {
                                foreach (ManagementObject app in apps)
                                {
                                    // No idea why two nulls are necessary, but it won't work any other way ...
                                    ManagementBaseObject outParams = app.InvokeMethod("Uninstall", null, null);

                                    // Variable to contain results of installation. Must cast outParams as string using ToString() method in order to use in test below.
                                    string results = outParams["ReturnValue"].ToString();

                                    // Progress bar step #5
                                    progressBar.PerformStep();

                                    // Use results variable (string version of outParams) to determine if install was a success (error 0) or failure.
                                    if (results.Equals("0"))
                                    {
                                        MessageBox.Show(proinput + " has been successfully uninstalled", "Removal Success", MessageBoxButtons.OK);
                                    }
                                    else
                                    {
                                        MessageBox.Show("Installation failed with Windows Installer error code: " + outParams["ReturnValue"], "Installation Error", MessageBoxButtons.OK);
                                        
                                        // Reset progress bar
                                        progressBar.Value = 0;
                                    }
                                }
                            }
                            // Set appexists to false if it isn't in the apps list
                            else
                            {
                                appexists = false;
                            }

                            // Results if the app wasn't found
                            if (appexists.Equals(false))
                            {
                                MessageBox.Show("Cannot find instance of " + proinput + " on " + target + ".", "Product not found", MessageBoxButtons.OK);

                                // Reset progress bar
                                progressBar.Value = 0;
                            }
                            
                        }
                        // Results if error #2 thrown
                        catch (Exception error2)
                        {
                            MessageBox.Show("Error establishing Win32 variables or connecting to target computer. Details: " + error2, "Uninstall Error #2", MessageBoxButtons.OK);

                            // Reset progress bar
                            progressBar.Value = 0;
                        }
                    }
                    // Results of var proceed if Cancel is pressed
                    else
                    {
                        MessageBox.Show("Uninstall of " + proinput + " cancelled.", "Cancelled", MessageBoxButtons.OK);

                        // Reset progress bar
                        progressBar.Value = 0;
                    }
                }
                // Results if no product selected
                else
                {
                    MessageBox.Show("Please select a product", "Error, No App Selected", MessageBoxButtons.OK);

                    // Reset progress bar
                    progressBar.Value = 0;
                }
            }
            // Results if no target PC is selected
            else
            {
                MessageBox.Show("Please select a target", "Error, No Target Selected", MessageBoxButtons.OK);

                // Reset progress bar
                progressBar.Value = 0;
            }
        }
    }
}
