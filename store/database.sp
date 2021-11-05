
#define DB_CORE_TABLE "ebans_users"
#define DB_CATEGORIES_TABLE "ebans_store_categories"
#define DB_ITEMS_TABLE "ebans_store_items"
#define DB_INVENTORY_TABLE "ebans_store_inventory"
#define DB_EQUIPPED_TABLE "ebans_store_equipped"
#define DB_LOOTBOX_TABLE "ebans_store_boxes"

// Get Categories
void DB_FetchCategories() {
    char query[512];
    g_StoreDatabase.Format(query, sizeof(query), "SELECT * FROM %s ORDER BY id ASC;", DB_CATEGORIES_TABLE);
    g_StoreDatabase.Query(DB_FetchCategories_Callback, query);
}

// Get Items
void DB_FetchItems() {
    char query[512];
    g_StoreDatabase.Format(query, sizeof(query), "SELECT * FROM %s ORDER BY id ASC;", DB_ITEMS_TABLE);
    g_StoreDatabase.Query(DB_FetchItems_Callback, query);
}



// Update Credits
void DB_GetClientCredits(int client) {

    char steamid[64], query[512];
    GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));

    g_StoreDatabase.Format(query, sizeof(query), "SELECT credits FROM %s WHERE authid = %s;", DB_CORE_TABLE, steamid);
    g_StoreDatabase.Query(DB_FetchCredits_Callback, query, GetClientUserId(client));
}

void DB_UpdateClientCredits(int client, int amount, MoneyAction action) {

    char steamid[64], query[512], operation[16];
    GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));

    // Queries
    FormatEx(operation, sizeof(operation), action == MA_Add ? "+" : "-");

    g_StoreDatabase.Format(query, sizeof(query), "UPDATE %s SET credits = credits %s '%d' WHERE authid = '%s';", DB_CORE_TABLE, operation, amount, steamid);
    g_StoreDatabase.Query(DB_SimpleCallback, query);
}

// Get Inventory
void DB_GetClientInventory(int client) {
    char steamid[64], query[512];
    GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));

    g_StoreDatabase.Format(query, sizeof(query), "SELECT itemid FROM %s WHERE steamid = '%s' ORDER BY id ASC;", DB_INVENTORY_TABLE, steamid);
    g_StoreDatabase.Query(DB_FetchInventory_Callback, query, GetClientUserId(client));
}

// Get Equipped
void DB_GetClientEquipped(int client) {
    char steamid[64], query[512];
    GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));

    g_StoreDatabase.Format(query, sizeof(query), "SELECT itemid FROM %s WHERE steamid = '%s' ORDER BY id ASC;", DB_EQUIPPED_TABLE, steamid);
    g_StoreDatabase.Query(DB_FetchEquipped_Callback, query, GetClientUserId(client));
}

// Add Inventory Item
void DB_AddInventoryItem(int client, int itemid) {
    char steamid[64], query[512];
    GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));

    g_StoreDatabase.Format(query, sizeof(query), "INSERT INTO %s(`steamid`, `itemid`) VALUES('%s', '%d');", DB_INVENTORY_TABLE, steamid, itemid);
    g_StoreDatabase.Query(DB_SimpleCallback, query);
}

// Remove Inventory Item
void DB_RemoveInventoryItem(int client, int itemid) {
    char steamid[64], query[512];
    GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));
    PrintToChatAll("Database::DB_RemoveInventoryItem --> %s", steamid);

    g_StoreDatabase.Format(query, sizeof(query), "DELETE FROM %s WHERE itemid = '%d' AND steamid = '%s';", DB_INVENTORY_TABLE, itemid, steamid);
    g_StoreDatabase.Query(DB_SimpleCallback, query);
}

void DB_RemoveLootboxByType(int client, BoxType type) {
    char steamid[64], query[512];
    GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));

    g_StoreDatabase.Format(query, sizeof(query), "DELETE FROM %s WHERE type = '%d' AND steamid = '%s' LIMIT 1;", DB_LOOTBOX_TABLE, view_as<int>(type), steamid);
    g_StoreDatabase.Query(DB_SimpleCallback, query);
}

// Equip Item
void DB_EquipItem(int client, int itemid) {
    char steamid[64], query[512];
    GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));

    g_StoreDatabase.Format(query, sizeof(query), "INSERT INTO %s(`steamid`, `itemid`) VALUES('%s', '%d');", DB_EQUIPPED_TABLE, steamid, itemid);
    g_StoreDatabase.Query(DB_SimpleCallback, query);
}

// Unequip Item
void DB_UnequipItem(int client, int itemid) {
    char steamid[64], query[512];
    GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));

    g_StoreDatabase.Format(query, sizeof(query), "DELETE FROM %s WHERE steamid = '%s' AND itemid = '%d';", DB_EQUIPPED_TABLE, steamid, itemid);
    g_StoreDatabase.Query(DB_SimpleCallback, query);
}

// Get Lootboxes
void DB_FetchLootboxes(int client) {
    char steamid[64], query[512];
    GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));

    g_StoreDatabase.Format(query, sizeof(query), "SELECT type, COUNT(*) as count FROM %s WHERE steamid = %s GROUP BY type;", DB_LOOTBOX_TABLE, steamid);
    g_StoreDatabase.Query(DB_OnBoxesReceived, query, GetClientUserId(client));
}

// void OnBoxesReceived() {
//     int count[BoxType] = {0, ...};
//     for(int i = 0; i < boxes.Length; i++) {
//         JSONObject _box = view_as<JSONObject>(boxes.Get(i));

//         int typeCount = _box.GetInt("count");
//         int type = _box.GetInt("type");

//         Box box;
//         for(int j = 0; j < typeCount; j++) {
//             box.boxtype = view_as<BoxType>(type);
//             g_alClientBoxes[client].PushArray(box, sizeof(Box));
//             count[box.boxtype]++;
//         }
//         delete _box;
//     }

//     // List boxes
//     for(int t = 0; t < _:BoxType; t++) {
//         eStore_Print(client, "Fetched %d %s%s\x08 Boxes!", count[t], g_sBoxRarityColors[t], g_sBoxRarities[t]);
//     }
// }




// enum struct Box {
//     int entity_id;
//     int owner;
//     BoxType boxtype;
// }

// Callbacks
void DB_FetchCredits_Callback(Database db, DBResultSet results, const char[] error, any data) {
    if(db == null || results == null || error[0] != '\0') {
        LogError("[STORE] Query failed: %s", error);
    }

    if(results.RowCount > 0) {
        int client = GetClientOfUserId(data);

        // Field
        int credits_field; results.FieldNameToNum("credits", credits_field);

        if(results.FetchRow()) {
            eStore[client].credits = results.FetchInt(credits_field);
        }
    }
}

void DB_FetchInventory_Callback(Database db, DBResultSet results, const char[] error, any data) {
    if(db == null || results == null || error[0] != '\0') {
        LogError("[STORE] Query failed: %s", error);
    }

    if(results.RowCount > 0) {
        int client = GetClientOfUserId(data);

        g_alInventory[client].Clear();

        // Field
        int itemid_field; results.FieldNameToNum("itemid", itemid_field);

        Item item;
        while(results.FetchRow()) {
            int index = results.FetchInt(itemid_field);

            g_alItems.GetArray(index, item, sizeof(Item));
            g_alInventory[client].PushArray(item, sizeof(Item));
            eStore_Print(client, "Pushed (Inventory): \x04%s", item.name);
        }
    }
}

void DB_FetchEquipped_Callback(Database db, DBResultSet results, const char[] error, any data) {
    if(db == null || results == null || error[0] != '\0') {
        LogError("[STORE] Query failed: %s", error);
    }

    if(results.RowCount > 0) {
        int client = GetClientOfUserId(data);

        g_alInventory[client].Clear();

        // Field
        int itemid_field; results.FieldNameToNum("itemid", itemid_field);

        Item item;
        while(results.FetchRow()) {
            int index = results.FetchInt(itemid_field);

            g_alItems.GetArray(index, item, sizeof(Item));
            g_alEquipped[client].PushArray(item, sizeof(Item));
            eStore_Print(client, "Pushed (Equipped): \x04%s", item.name);
        }
    }
}

void DB_OnBoxesReceived(Database db, DBResultSet results, const char[] error, any data) {
    if(db == null || results == null || error[0] != '\0') {
        LogError("[STORE] Query failed: %s", error);
    }
   

    if(results.RowCount > 0) {
        int client = GetClientOfUserId(data);
        
        g_alClientBoxes[client].Clear();

        int count[BoxType] = {0, ...};

        int fields[2];
        results.FieldNameToNum("type", fields[0]);
        results.FieldNameToNum("count", fields[1]);

        while(results.FetchRow()) {
            int t = results.FetchInt(fields[0]);
            int c = results.FetchInt(fields[1]);

            Box box;
            for(int i = 0; i < c; i++) {
                box.boxtype = view_as<BoxType>(t);
                g_alClientBoxes[client].PushArray(box, sizeof(Box));
                count[box.boxtype-1]++;
            }
        }
    }
}

void DB_FetchCategories_Callback(Database db, DBResultSet results, const char[] error, any data) {
    if(db == null || results == null || error[0] != '\0') {
        LogError("[STORE] Query failed: %s", error);
    }

    g_alCategories.Clear();
    if(results.RowCount > 0) {

        Category category; int fields[3];
		
        results.FieldNameToNum("id", fields[0]);
        results.FieldNameToNum("name", fields[1]);
        results.FieldNameToNum("flags", fields[2]);

        while(results.FetchRow()) {
			category.id = results.FetchInt(fields[0]);

            results.FetchString(fields[1], category.name, sizeof(Category::name));
            results.FetchString(fields[2], category.flags, sizeof(Category::flags));

            g_alCategories.PushArray(category, sizeof(Category));
        }
    }
}

void DB_FetchItems_Callback(Database db, DBResultSet results, const char[] error, any data) {
    if(db == null || results == null || error[0] != '\0') {
        LogError("[STORE] Query failed: %s", error);
    }

    g_alItems.Clear();
    if(results.RowCount > 0) {

        Item item; int fields[5];
		
        results.FieldNameToNum("id", fields[0]);
        results.FieldNameToNum("name", fields[1]);
        results.FieldNameToNum("categoryid", fields[2]);
        results.FieldNameToNum("price", fields[3]);
        results.FieldNameToNum("modelpath", fields[4]);

        while(results.FetchRow()) {

			item.itemid = results.FetchInt(fields[0]);
			item.categoryid = results.FetchInt(fields[2]);
			item.price = results.FetchInt(fields[3]);

            results.FetchString(fields[1], item.name, sizeof(Item::name));
            // results.FetchString(fields[2], item.modelpath, sizeof(Item::modelpath));

            g_alItems.PushArray(item, sizeof(Item));
        }
    }
}

void DB_SimpleCallback(Database db, DBResultSet results, const char[] error, any data) {
    if(db == null || results == null || error[0] != '\0') {
        LogError("[STORE] Query failed: %s", error);
    }
}