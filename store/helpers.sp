stock bool eStore_Helpers_IsPluginValid(Handle plugin) {
	Handle hIterator = GetPluginIterator();
	bool bIsValid = false;
	
	while (MorePlugins(hIterator)) {
		if (plugin == ReadPlugin(hIterator)) {
			bIsValid = (GetPluginStatus(plugin) == Plugin_Running);
			break;
		}
	}
	delete hIterator;
	return bIsValid;
}

stock bool eStore_Helpers_Substring(char[] dest, int destSize, char[] source, int sourceSize, int start, int end) {
    if (end < start || end > (sourceSize-1)) {
        strcopy(dest, destSize, NULL_STRING);
        return false;
    }
    else {
        strcopy(dest, (end-start+1), source[start]);
        return true;
    }
} 

stock void eStore_HUD(int client, char[] channel, char[] color, char[] color2, char[] effect, char[] fadein, char[] fadeout, char[] fxtime, char[] holdtime, char[] message, char[] x, char[] y){
	if(!eStore_IsValidReference(g_iHudEntity)) {
		int ent = CreateEntityByName("game_text");
		DispatchKeyValue(ent, "channel", channel);
		DispatchKeyValue(ent, "color", color);
		DispatchKeyValue(ent, "color2", color2);
		DispatchKeyValue(ent, "effect", effect);
		DispatchKeyValue(ent, "fadein", fadein);
		DispatchKeyValue(ent, "fadeout", fadeout);
		DispatchKeyValue(ent, "fxtime", fxtime);         
		DispatchKeyValue(ent, "holdtime", holdtime);
		DispatchKeyValue(ent, "spawnflags", "0");
		DispatchKeyValue(ent, "x", x);
		DispatchKeyValue(ent, "y", y);         
		DispatchSpawn(ent);
		g_iHudEntity = EntIndexToEntRef(ent);
	}
	DispatchKeyValue(g_iHudEntity, "message", message);
	SetVariantString("!activator");
	AcceptEntityInput(g_iHudEntity, "display", client);
}

stock bool eStore_IsValidReference(int ref) {
	int iEnt = EntRefToEntIndex(ref);
	return (iEnt > MaxClients && IsValidEntity(iEnt))
}
