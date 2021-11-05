// Called when plugins gets loaded
public void OnPluginStart() {
    eStore_OnPluginStart();
    eStore_Forwards_OnPluginStart();
    
    // Creates all command

    // Testing Purposes Only
    RegConsoleCmd("sm_store", Command_eStore);

    // Commands
    RegConsoleCmd("sm_credits", Command_eCredits);

    // Dev Commands
    RegConsoleCmd("sm_addcredits", Command_eAddCredits);
    RegConsoleCmd("sm_removecredits", Command_eRemoveCredits);
    RegConsoleCmd("sm_showinventory", Command_eShowInventory);
    RegConsoleCmd("sm_reloadstuff", Command_eReloadStuff);
    RegConsoleCmd("sm_spawnbox", Command_eSpawnBox);
    RegConsoleCmd("sm_setanimatedtag", Command_eSetAnimatedClantag);
}

// On Plugin End
public void OnPluginEnd() {
    eStore_OnPluginEnd();
}