Unit Testing Databases with tSQLt Part 1 – Installation and Setup

by DATA-CENTRIC on OCTOBER 13, 2011

This is the first in a series of articles about my experiences (re)creating a database project from scratch using the tSQLt unit testing framework. I will be using an open source project I have been playing with on and off for a few years – Log4TSql which is an open source database logging and exception handling block for SQL2005+ Or rather it will be if I ever finish it 🙂

I’ve used this simple logging framework in some form or other on nearly every project I’ve worked on so it is already tried and tested. However, I think that if I am serious about other people or businesses adopting this I need to support it with a suite of tests that will give some measure of confidence that it does what it is supposed to. I also have some ideas for further improvements and these will definitely need to be properly unit tested.  Finally, the fact this this is open source makes it very easy for me to publish all the code and associated tests withoutworrying about intellectual property rights of any of my customers.  So having elected to use tSQLt as my testing framework lets’s get started.

The first step to utilising this framework is to download the latest version from the tSQLt download area at SourceForge. The current version at the time of writing is build .11 released on 17th July 2011.  In addition to the release notes, this zip file contains two SQL scripts.  You will need to run both of these in the development database in which you are planning to start writing unit tests. Remember to select the correct database before running either of these scripts. Don’t do what I did and dump everything in master 🙂

SetClrEnabled.sql – Enables CLR if not already enabled.  It also sets TRUSTWORTHY ON which allows CLR routines a much deeper level of acces to run on your SQL Server instance.  This is unlikley to be something you would want to do in production but in a DEV environment it should be fine – and you shouldn’t be writing or running unit tests anywhere other than DEV anyway. tSQLt.class.sql – this sets up the schemas, ant tables and all modules (both CLR and SQL) which make up the complete unit-testing framework

Run the above scripts in the order listed and from the second script you will see something like this:

Compiled at 2011-10-08 18:06:27.230 The module 'DefaultResultFormatter' depends on the missing object 'tSQLt.TableToText'. The module will still be created; however, it cannot run successfully until the object exists. The module 'RunTestClass' depends on the missing object 'tSQLt.Run'. The module will still be created; however, it cannot run successfully until the object exists. The module 'Run' depends on the missing object 'tSQLt.Private_RunTestClass'. The module will still be created; however, it cannot run successfully until the object exists. The module 'Private_RenameObjectToUniqueName' depends on the missing object 'tSQLt.SuppressOutput'. The module will still be created; however, it cannot run successfully until the object exists. The module 'SetFakeViewOff' depends on the missing object 'tSQLt.Private_SetFakeViewOff_SingleView'. The module will still be created; however, it cannot run successfully until the object exists.

You can safely ignore the reported object dependency warnings and on successful execution your database structure (assuming you have nothing else in it) will look like this:

That’s it, tSQL is installed and ready to go and you are now ready to write your first test – which I will cover in the next post in this series .

I think that the only thing that is missing from the release package is a means of reverting to the pre-tSQLt state.  So I have provided this tSQLt Removal Script which will remove all traces of tSQLt from the selected database.  The only thing this script won’t do is revert the CLR related changes since they may have already been enabled and you won’t thank me if this script turns everything off.  UPDATE: The removal script will work with versions up to v.0.12.  With effect from v1.0.4351.28410, tSQLt comes with a built in uninstaller sproc called [tSQLt].[Uninstall].

In the meantime, you can check out the Quick Start Guide or, for more detail the tSQt User Guide.

In Part 2 we will begin writing our first tests.

Tagged as: TDD, tSQLt

