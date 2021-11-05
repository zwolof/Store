void eStore_Print(int client, char[] message, any ...) {
    if(client && IsClientInGame(client) && !IsFakeClient(client)) {
        char szBuffer[PLATFORM_MAX_PATH], szNewMessage[PLATFORM_MAX_PATH];
        Format(szBuffer, sizeof(szBuffer), PREFIX..." \x08%s", message);
        VFormat(szNewMessage, sizeof(szNewMessage), szBuffer, 3);

        Handle hBf = StartMessageOne("SayText2", client, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
		if(hBf != null)
		{
			if(GetUserMessageType() == UM_Protobuf)
			{
				Protobuf hProtoBuffer = UserMessageToProtobuf(hBf);
				hProtoBuffer.SetInt("ent_idx", client);
				hProtoBuffer.SetBool("chat", true);
				hProtoBuffer.SetString("msg_name", szNewMessage);
				hProtoBuffer.AddString("params", "");
				hProtoBuffer.AddString("params", "");
				hProtoBuffer.AddString("params", "");
				hProtoBuffer.AddString("params", "");
			}
			else
			{
				BfWrite hBfBuffer = UserMessageToBfWrite(hBf);
				hBfBuffer.WriteByte(client);
				hBfBuffer.WriteByte(true);
				hBfBuffer.WriteString(szNewMessage);
			}
		}
		EndMessage();
    }
}

float GetAimOrigin(int client, float hOrigin[3])
{
	float vAngles[3], fOrigin[3];
	GetClientEyePosition(client,fOrigin);
	GetClientEyeAngles(client, vAngles);
	
	Handle trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, trNoPlayers);
	
	if(TR_DidHit(trace)) {
		TR_GetEndPosition(hOrigin, trace);
		CloseHandle(trace);
		return 1;
	}
	
	CloseHandle(trace);
	return 0;
}

public bool trNoPlayers(int iEnt, int iBitMask, any iData) {
	return !(iEnt == iData ||1 <= iEnt <= MaxClients);
}

bool eStore_IsValidClient(int client) {
    return view_as<bool>(IsClientInGame(client) && !IsFakeClient(client));
}

float eUtils_GetSecondsFromMinutes(int minutes) {
    return (minutes * 60.0);
}

void eStore_SetMenuTitle(Menu menu, int client) {
    menu.SetTitle(STORE_MENUTITLE..."\n"...STORE_CREDITSNAME_UC...": %d\n▬▬▬▬▬▬▬▬▬▬▬▬", eStore[client].credits);
}

bool eStore_UserHasItem(int client, int itemid) {
    if(g_alInventory[client] == null) return false;

    int size = g_alInventory[client].Length;
    if(size == 0) return false;

    Item item;
    for(int i = 0; i < size; i++) {
        g_alInventory[client].GetArray(i, item, sizeof(Item));

        // If IDs are equal, they have the item
        if(item.itemid == itemid) {
            return true;
        }
    }
    return false;
}

public int eStore_FindBoxByEntId(int ent) {

    if(g_alBoxes == null) return -1;
    int len = g_alBoxes.Length;
    if(len <= 0) return -1;

    Box box;
    for(int i = 0; i < len; i++) {
        g_alBoxes.GetArray(i, box, sizeof(Box));

        if(box.entity_id == ent) {
            return i
        }
    }
    return -1;
}

public int eStore_GetBoxCountByType(int client, BoxType type) {
    int len = g_alClientBoxes[client].Length;
    if(len <= 0) return -1;

    Box box;
    int count = 0;
    for(int i = 0; i < len; i++) {
        g_alClientBoxes[client].GetArray(i, box, sizeof(Box));
        if(type == box.boxtype) {
            count++
        }
    }
    return count;
}

public int eStore_FindBoxIndexByType(int client, BoxType type) {
    int len = g_alClientBoxes[client].Length;
    if(len <= 0) return -1;

    Box box;
    for(int i = 0; i < len; i++) {
        g_alClientBoxes[client].GetArray(i, box, sizeof(Box));
        if(type == box.boxtype) {
            return i;
        }
    }
    return -1;
}

public int eStore_GetRandomItemIndexByPriceRange(int min, int max) {
    int len = g_alItems.Length;
    if(len <= 0) return -1;

    Item item;
    for(int i = 0; i < len; i++) {
        g_alItems.GetArray(i, item, sizeof(Item));
        if(min <= item.price <= max) {
            return i;
        }
    }
    return -1;
}

public bool eStore_AddItem(int client, Item item) {
    if(g_alInventory[client] != null) {
        g_alInventory[client].PushArray(item);
        return true;
    }
    else {
        eStore_Print(client, "Could not add item, contact a developer");
        return false;
    }
    return false;
}

public StringMap eStore_GetBoxRewardByType(BoxType type) {
    StringMap rewards = new StringMap();

    rewards.SetValue("credits", 0);
    
    // Credits
    if(GetRandomInt(1, 100) <= g_iCreditsPerType[type]) {

        // Min & Max boundaries
        int min = g_iCreditIntervalPerType[type][0];
        int max = g_iCreditIntervalPerType[type][1];

        // Get random credit count
        int credits = GetRandomInt(min, max);
        rewards.SetValue("credits", credits);
    }

    switch(type) {
        case BoxType_Rare: {
            int len = g_alItems.Length;
            if(len > 0) {
                // int index = eStore_GetRandomItemIndexByPriceRange(200, 500);
                Item item;
                // g_alItems.GetArray(index, item, sizeof(Item));
                g_alItems.GetArray(2, item, sizeof(Item));
                rewards.SetArray("item", item, sizeof(Item));
            }
        }
        case BoxType_Epic: {
            int catLen = g_alCategories.Length;
            int itmLen = g_alItems.Length;
            char sPossibleItems[][] = { "trails", "playerskins" };

            if(catLen > 0) {
                int randCat = GetRandomInt(0, sizeof(sPossibleItems)-1);

                Category category;
                g_alCategories.GetArray(randCat, category, sizeof(Category));

                if(itmLen > 0) {
                    Item item;
                    eStore_GetRandomItemFromCategory(category, item, sizeof(Item));
                    rewards.SetArray("item", item, sizeof(Item));
                }
            }
        }
    }
    return rewards;
}

public void eStore_GetRandomItemFromCategory(Category category, Item item, int size) {
    int len = g_alCategories.Length;
    if(len > 0) {
        int random = GetRandomInt(0, len-1);
        
        Item randItem;
        for(int i = 0; i < g_alItems.Length; i++) {
            g_alItems.GetArray(i, randItem, sizeof(Item));
            if(item.categoryid == random) {
                g_alItems.GetArray(i, item, size);
                break;
            }
        }
    }
}

public int eStore_FindItemIndexById(ArrayList list, int id) {

    // Is this a valid ArrayList?
    if(!IsValidArrayList(list)) return -1;

    Item item;
    for(int i = 0; i < list.Length; i++) {
        list.GetArray(i, item, sizeof(Item));

        // If IDs are equal, we found it.
        if(item.itemid == id) {
            return i;
        }
    }
    return -1;
}

public bool eStore_RemoveItemByCategory(ArrayList list, int id) {

    // Is this a valid ArrayList?
    if(!IsValidArrayList(list)) return false;

    Item item;
    for(int i = 0; i < list.Length; i++) {
        list.GetArray(i, item, sizeof(Item));

        // If IDs are equal, we found it.
        if(item.categoryid == id) {
            list.Erase(i);
            return true;
        }
    }
    return false;
}

public ArrayList eStore_GetItemsByCategoryId(ArrayList list, int catid) {
    // Is this a valid ArrayList?
    if(!IsValidArrayList(list)) return null;

    ArrayList temp = new ArrayList(sizeof(Item));

    Item item;
    for(int i = 0; i < list.Length; i++) {
        list.GetArray(i, item, sizeof(Item));

        // If IDs are equal, we found it.
        if(item.categoryid == catid) {
            temp.PushArray(item);   
        }
    }
    return temp;
}

// public bool eStore_GetEquippedColor(int client, char[] str, int maxlen) {
//     int len = g_alCategories.Length;
//     if(len > 0) {
//         // strcopy()
//     }
//     return false;
// }

// public int eStore_FindCategoryByShortname(char[] shortname) {
//     int len = g_alCategories.Length;
    
//     if(len > 0) {
//         Category category;
//         for(int i = 0; i < len; i++) {
//             g_alCategories.GetArray(i, category, sizeof(Category));
//             if(StrEqual(category.shortname, category, false)) {
//                 return i;
//             }
//         }
//     }
//     return -1;
// }
// public StringMap eStore_Test(Item item, int count) {
//     StringMap map = new StringMap();
//     map.setValue("item", item);
//     map.setValue("count", count);
//     return map;
// }

public int eStore_FindCategoryByItemId(ArrayList list, int id) {

    // Is this a valid ArrayList?
    if(!IsValidArrayList(list)) return -1;

    Item item;
    for(int i = 0; i < list.Length; i++) {
        list.GetArray(i, item, sizeof(Item));

        // If IDs are equal, we found it.
        if(item.itemid == id) {
            return item.categoryid;
        }
    }
    return -1;
}

public bool eStore_CategoryExistsInArray(ArrayList array, int catid) {
    if(!IsValidArrayList(array)) return false;

    Item item;
    for(int i = 0; i < array.Length; i++) {
        // Get The Array
        array.GetArray(i, item, sizeof(Item));
        if(item.categoryid == catid) {
            return true;
        }
    }
    return false;
}

public int eStore_FindItemIndexByCategory(ArrayList array, int catid) {
    if(!IsValidArrayList(array)) return -1;

    Item item;
    for(int i = 0; i < array.Length; i++) {

        // Get The Array
        array.GetArray(i, item, sizeof(Item));
        if(item.categoryid == catid) {
            return i;
        }
    }
    return -1;
}

public int eStore_GetOccouranceCountByItemId(ArrayList list, int itemid) {

    // Is this a valid ArrayList?
    if(!IsValidArrayList(list)) return 0;
    
    // Variables
    Item item;
    int count = 0;

    // Loop the list, get the items and do a check
    for(int i = 0; i < list.Length; i++) {
        list.GetArray(i, item, sizeof(Item));

        if(item.itemid == itemid) {
            count++;
        }
    }
    return count;
}

public int eStore_GetOccouranceCountByCategoryId(ArrayList list, int id) {

    // Is this a valid ArrayList?
    if(!IsValidArrayList(list)) return 0;
    
    // Variables
    Item item;
    int count = 0;

    // Loop the list, get the items and do a check
    for(int i = 0; i < list.Length; i++) {
        list.GetArray(i, item, sizeof(Item));

        if(item.categoryid == id) {
            count++;
        }
    }
    return count;
}

public int eStore_FindItemIdByName(ArrayList list, const char[] sName) {

     // Is this a valid ArrayList?
    if(!IsValidArrayList(list)) return -1;

    Item item;
    for(int i = 0; i < list.Length; i++) {
        list.GetArray(i, item, sizeof(Item));

        if(StrEqual(item.name, sName, false)) {
            return item.itemid;
        }
    }
    return -1;
}

bool eStore_IsItemEquipped(int client, int id) {
    if(g_alEquipped[client] == null || g_alInventory[client] == null) {
        return false;
    }
    if(g_alEquipped[client].Length == 0) {
        return false;
    }

    // Logic
    Item item; Item equipped;
    for(int i = 0; i < g_alEquipped[client].Length; i++) {
        g_alEquipped[client].GetArray(i, equipped, sizeof(Item));

        if(equipped.itemid == id) {
            return true;
        }
    }
    return false;
}

void EquipItem(int client, Item item) {
    g_alEquipped[client].PushArray(item);

    if(g_dataOrigin == DataOrigin_API) {
        API_EquipItem(client, item.itemid);
    }

    if(g_dataOrigin == DataOrigin_DB) {
        DB_EquipItem(client, item.itemid);
    }

    eStore_Print(client, "Equipped Item \"\x0F%s\x08\"", item.name);
}

void UnequipItem(int client, Item item) {
    if(eStore_IsItemEquipped(client, item.itemid)) {
        int index = eStore_FindItemIndexByCategory(g_alEquipped[client], item.categoryid);

        if(index != -1) {
            
            if(g_dataOrigin == DataOrigin_API) {
                API_UnequipItem(client, item.itemid);
            }

            if(g_dataOrigin == DataOrigin_DB) {
                DB_UnequipItem(client, item.itemid);
            }

            g_alEquipped[client].Erase(index);
            eStore_Print(client, "\x08Unequipped item \"\x0F%s\x08\"", item.name);
        }
    }
}

bool IsValidArrayList(ArrayList list) {
    return !(list == null || list.Length == 0);
}

bool eStore_SeparateThousandsInNumber(const char[] number, char[] buffer, int maxlen) {
    for(int i = maxlen; i >= 0; i--) {
        if(number[i] == '0') {
            ExplodeString(number, number[i], )
        }
    }
}