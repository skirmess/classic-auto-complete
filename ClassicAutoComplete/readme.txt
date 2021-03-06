
ClassicAutoComplete

Restores the classic auto complete functionality of the send mail frame and adds your alts to the list used for auto completion. 

While you type, the add-on searches for the first match in the following order:

 * One of your alts
 * One of your friends
 * One of your guildies

The autocompleted text will be grayed out so if you continue typing the text is overwritten and the search is refined.

This add-on saves the name of all your alts whenever you login with them. You do not have to put them on your friend list.

The following commands exist

 * /autocomplete add charname
   This command lets you add any char to the list. This char will be treated the same as if it would be one of your alts.
 * /autocomplete block charname
   This command blocks a char. This char will never be added to your alt list and will not be used for auto completion. If this char is on your friend list or in your guild, it will still be used for auto completion because the autocompletion for friend list and guild is down via the Blizzard API.
 * /autocomplete remove charname
   Removed this char from the alt list. This comman dis used to remove a previously added alt or to unblock a previously blocked alt.
 * /autocomplete list
   Lists your alt list.

*** Changelog

Version 16
 * Updated TOC for WoW 8.0.0 (BfA)

Version 15
 * Updated TOC for WoW 7.0.0

Version 14
 * Updated TOC for WoW 6.1.0
 * Changed project web page to GitHub
   https://github.com/skirmess/classic-auto-complete

Version 13
 * Added support for connected realms.
 * Removed the default drop down in the mail recipient field
 * Removed calendar support.
 * Updated TOC for WoW 6.0.0

Version 12
 * Replaced GetCVar("realmName") with GetRealmName() (thanks danidaf)
 * Updated TOC for WoW 5.4.0

Version 11
 * Updated TOC for WoW 5.2.0

Version 10
 * Updated for MoP.

Version 9
 * Updated TOC for WoW 4.3.0

Version 8
 * Updated TOC for WoW 4.0.1

Version 7
 * Updated TOC for WoW 3.3.5

Version 6
 * Stop leaking globals.
 * No longer use an XML file.
 * Added classic auto complete behaviour to the Blizzard calendar.

Version 5
 * You can now add, remove or block chars via a command line interface.
 * /autocomplete add charname
   This command lets you add any char to the list. This char will be treated the same as if it would be one of your alts.
 * /autocomplete block charname
   This command blocks a char. This char will never be added to your alt list and will not be used for auto completion. If this char is on your friend list or in your guild, it will still be used for auto completion because the autocompletion for friend list and guild is down via the Blizzard API.
 * /autocomplete remove charname
   Removed this char from the alt list. This comman dis used to remove a previously added alt or to unblock a previously blocked alt.
 * /autocomplete list
   Lists your alt list.
 * Alts no longer expire after 31 days. You have to use the remove function to
   remove them after you've deleted an alt.

Version 4
 * Updated TOC for WoW 3.2
 * Added license information
 * Added link to project main page at
  http://code.google.com/p/classic-auto-complete/

Version 3
Bugfix: Call SendMailFrame_Update() after every new character. This fixes an issue where it was not always possible to send a mail although it should have been.

Version 2
Bugfix: Don't add an alt to the list if the alt is also in the guild

Version 1
Initial release
