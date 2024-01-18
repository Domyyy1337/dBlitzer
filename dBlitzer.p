/*
 
 
Befehle:
/berstellen [id][radius][geschwindigkeit]
    Mit diesem Befehl kannst du einen Blitzer erstellen.
/bloeschen
    Sobald du in der nähe eines Blitzers bist, wird er automatisch gelöescht.
/addbcreator [playerid]
    Mit diesem Befehl kannst du einem Spieler die Befugnis geben einen Blitzer zu erstellen.
/removebcreator [playerid]
    Mit diesem Befehl kannst du einem Spieler die Befugnis nehmen einen Blitzer zu erstellen.
/addnoblitz [playerid]
    Mit diesem Befehl kannst du einen Spieler aus dem Blitzprogramm ausschließen, d.h. er kann nicht mehr geblitzt werden.
/removenoblitz [playerid]
    Mit diesem Befehl kannst du einen Spieler wieder in das Blitzprogramm hinzufügen, d.h. er kann wieder geblitzt werden.
    
Features:
-Blitzer schnell und einfach ingame erstellen
-Blitzerberechtigung geben
-NoBlitz Funktion, per Befehl kann eingestellt werden ob man geblitzt werden kann oder nicht. Praktisch für aduty.
 
Gescriptet für Midnight Roleplay.
Erstellt von Dominik. .
 
Mehrmals getestet,
ein kleiner Fehler:
Der Timer überprüft alle 1,5 Sekunden ob man in der Nähe eines Blitzers ist.
Bei hohem Blitzradius wird man evtl. 2x geblitzt.
 
*/
#define FILTERSCRIPT
#include <a_samp>
#include <SII>
#include <rCmd>
#define MAX_BLITZER 10
#define MIN_RADIUS  10
#define MAX_RADIUS  50
#define MIN_SPEED   10
#define MAX_SPEED   100
#define Verzeichnis "Accounts"
forward BlitzCheck(playerid);
#define cGrün      0x23FF00FF
#define cRot        0xE10000FF
#define cOrange     0xFF8200FF
#define cBlau       0x0A00FFFF
enum BlitzerInfo
{
    Float:bX,
    Float:bY,
    Float:bZ,
    bRadius,
    bGeschwindigkeit,
    Text3D:bLabel,
    bObjekt
};
new Blitzer[MAX_BLITZER][BlitzerInfo];
public OnFilterScriptInit()
{
    for(new b = 1; b < MAX_BLITZER; b++)
    {
        bLoad(b);
    }
    print("\n--------------------------------------");
    print(" dBlitzer loaded ...");
    print(" (c)Midnight Roleplay");
    print(" Script by Dominik. .");
    print("--------------------------------------\n");
    return 1;
}
public BlitzCheck(playerid)
{
    new bool:WurdeGeblitzt[MAX_PLAYERS] = false, speed = GetPlayerSpeed(playerid,true), strafe, sName[24];
    GetPlayerName(playerid,sName,24);
    if(IsPlayerInAnyVehicle(playerid))
    {
        for(new b = 1; b < MAX_BLITZER; b++)
        {
            if(IsPlayerInRangeOfPoint(playerid,Blitzer[b][bRadius],Blitzer[b][bX],Blitzer[b][bY],Blitzer[b][bZ]))
            {
                if(speed > Blitzer[b][bGeschwindigkeit])
                {
                    new sFile[64]; format(sFile,64,"%s/%s.ini",Verzeichnis,sName);
                    INI_Open(sFile);
                    if(INI_ReadInt("bNoBlitz") != 1)
                    {
                        WurdeGeblitzt[playerid] = true;
                        strafe = speed * 10 - Blitzer[b][bGeschwindigkeit];
                    } else return SendClientMessage(playerid,cOrange,"Du wurdest geblitzt! musstest aber keine Strafe bezahlen da die einen bNoBlitz Rang hast!");
                }
            }
        }
    }
    if(WurdeGeblitzt[playerid] == true)
    {
        GivePlayerMoney(playerid,-strafe); new string[128];
        format(string,128,"|| %s wurde mit %d km/h geblitzt! Er musste $%d Strafe bezahlen!",sName,speed,strafe);
        SendClientMessageToAll(cBlau,string);
        return 1;
    }
    return 1;
}
rCmd[]->bloeschen(playerid)
{
    new sFile[64], sName[24];
    GetPlayerName(playerid,sName,24);
    format(sFile,64,"%s/%s.ini",Verzeichnis,sName);
    INI_Open(sFile);
    if(INI_ReadInt("bErsteller") != 1) return SendClientMessage(playerid,cRot,"Du bist nicht berechtigt einen Blitzer zu löschen!");
    for(new b = 1; b < MAX_BLITZER; b++)
    {
        if(!IsPlayerInRangeOfPoint(playerid,5.0,Blitzer[b][bX],Blitzer[b][bY],Blitzer[b][bZ])) return SendClientMessage(playerid,cRot,"Du bist nicht nahe Genug an einem Blitzer!");
        new bFile[64]; format(bFile,64,"Blitzer/%d.ini",b); INI_Remove(bFile);
        DestroyObject(Blitzer[b][bObjekt]); Delete3DTextLabel(Blitzer[b][bLabel]);
        Blitzer[b][bObjekt] = 0; Blitzer[b][bX] = 0; Blitzer[b][bY] = 0; Blitzer[b][bZ] = 0; Blitzer[b][bRadius] = 0; Blitzer[b][bGeschwindigkeit] = 0;
        SendClientMessage(playerid,cGrün,"Blitzer erfolgreich geloescht!"); return 1;
    } return 1;
}
rCmd[ddd]->berstellen(playerid,success,blitzerid,radius,geschwindigkeit)
{
    new sFile[64], sName[24];
    GetPlayerName(playerid,sName,24);
    format(sFile,64,"%s/%s.ini",Verzeichnis,sName); INI_Open(sFile);
    if(INI_ReadInt("bErsteller") != 1) return SendClientMessage(playerid,cRot,"Du bist nicht berechtigt einen Blitzer zu erstellen!");
    INI_Close();
    if(!success) return SendClientMessage(playerid,cRot,"Verwendung: /berstellen [blitzerid][radius][geschwindigkeit]");
    if(blitzerid >= 1 && blitzerid <= MAX_BLITZER)
    {
        if(radius <= MAX_RADIUS && radius >= MIN_RADIUS)
        {
            if(geschwindigkeit <= MAX_SPEED && geschwindigkeit >= MIN_RADIUS)
            {
                new Float:X,Float:Y,Float:Z;
                GetPlayerPos(playerid,X,Y,Z); bCreate(blitzerid,X,Y,Z,geschwindigkeit,radius);
                return 1;
                } else {
                    new string[64];
                    format(string,64,"Die Geschwindigkeit muss zwischen %d und %d liegen!",MIN_SPEED,MAX_SPEED);
                    return SendClientMessage(playerid,cRot,string); }
            } else {
                new string[64];
                format(string,64,"Der Radius muss zwischen %d und %d liegen!",MIN_RADIUS,MAX_RADIUS);
                return SendClientMessage(playerid,cRot,string); }
        } else {
            new string[64];
            format(string,64,"Die BlitzerID muss zwischen 1 und %d liegen!",MAX_BLITZER);
            return SendClientMessage(playerid,cRot,string); }
}
rCmd[d]->addbcreator(playerid,success,addplayerid)
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,cRot,"Du bist kein RCON-Administrator!");
    if(!success) return SendClientMessage(playerid,cRot,"Verwendung: /addbcreator [addplayerid]");
    if(IsPlayerConnected(addplayerid) && addplayerid != INVALID_PLAYER_ID)
    {
        new sFile[64], aName[24], sName[24];
        GetPlayerName(playerid,sName,24); GetPlayerName(addplayerid,aName,24);
        format(sFile,64,"%s/%s.ini",Verzeichnis,aName);
        INI_Open(sFile); INI_WriteInt("bErsteller",1);
        INI_Save(); INI_Close();
        new string[2][64];
        format(string[0],64,"Du hast %s erfolgreich den bErsteller Rang gegeben!",aName);
        format(string[1],63,"%s hat dir den den bErsteller Rang gegeben!",sName);
        SendClientMessage(playerid,cGrün,string[0]); SendClientMessage(addplayerid,cOrange,string[1]);
        return 1;
    } else return SendClientMessage(playerid,cRot,"Ungültige SpielerID!");
}
rCmd[d]->removebcreator(playerid,success,addplayerid)
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,cRot,"Du bist kein RCON-Administrator!");
    if(!success) return SendClientMessage(playerid,cRot,"Verwendung: /removebcreator [addplayerid]");
    if(IsPlayerConnected(addplayerid) && addplayerid != INVALID_PLAYER_ID)
    {
        new sFile[64], aName[24], sName[24];
        GetPlayerName(playerid,sName,24); GetPlayerName(addplayerid,aName,24);
        format(sFile,64,"%s/%s.ini",Verzeichnis,aName);
        INI_Open(sFile); INI_WriteInt("bErsteller",0);
        INI_Save(); INI_Close(); new string[2][64];
        format(string[0],64,"Du hast %s erfolgreich den bErsteller Rang entzogen!",aName);
        format(string[1],64,"%s hat dir den den bErsteller Rang entzogen!",sName);
        SendClientMessage(playerid,cGrün,string[0]); SendClientMessage(addplayerid,cOrange,string[1]);
        return 1;
    } else return SendClientMessage(playerid,cRot,"Ungültige SpielerID!");
}
rCmd[d]->removenoblitz(playerid,success,addplayerid)
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,cRot,"Du bist kein RCON-Administrator!");
    if(!success) return SendClientMessage(playerid,cRot,"Verwendung: /removenoblitz [addplayerid]");
    if(IsPlayerConnected(addplayerid) && addplayerid != INVALID_PLAYER_ID)
    {
        new sFile[64], aName[24], sName[24], string[2][64];
        GetPlayerName(playerid,sName,24); GetPlayerName(addplayerid,aName,24);
        format(sFile,64,"%s/%s.ini",Verzeichnis,aName);
        INI_Open(sFile); INI_WriteInt("bNoBlitz",0);
        INI_Save(); INI_Close();
        format(string[0],64,"Du hast %s erfolgreich den bNoBlitz Rang entzogen!",aName);
        format(string[1],63,"%s hat dir den den bNoBlitz Rang entzogen!",sName);
        SendClientMessage(playerid,cGrün,string[0]); SendClientMessage(addplayerid,cOrange,string[1]);
        return 1;
    } else return SendClientMessage(playerid,cRot,"Ungültige SpielerID!");
}
rCmd[d]->addnoblitz(playerid,success,addplayerid)
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,cRot,"Du bist kein RCON-Administrator!");
    if(!success) return SendClientMessage(playerid,cRot,"Verwendung: /addnoblitz [addplayerid]");
    if(IsPlayerConnected(addplayerid) && addplayerid != INVALID_PLAYER_ID)
    {
        new sFile[64], aName[24], sName[24], string[2][64];
        GetPlayerName(playerid,sName,24); GetPlayerName(addplayerid,aName,24);
        format(sFile,64,"%s/%s.ini",Verzeichnis,aName);
        INI_Open(sFile); INI_WriteInt("bNoBlitz",1);
        INI_Save(); INI_Close();
        format(string[0],64,"Du hast %s erfolgreich den bNoBlitz Rang gegeben!",aName);
        format(string[1],63,"%s hat dir den den bNoBlitz Rang gegeben!",sName);
        SendClientMessage(playerid,cGrün,string[0]); SendClientMessage(addplayerid,cOrange,string[1]);
        return 1;
    } else return SendClientMessage(playerid,cRot,"Ungültige SpielerID!");
}
 
public OnPlayerConnect(playerid)
{
    SetTimerEx("BlitzCheck",1500,true,"i",playerid);
    return 1;
}
stock bCreate(blitzerid,Float:X,Float:Y,Float:Z,geschwindigkeit,radius)
{
    new bFile[64];
    format(bFile,64,"Blitzer/%d.ini",blitzerid);
    INI_Open(bFile);
    INI_WriteFloat("X",X); INI_WriteFloat("Y",Y);
    INI_WriteFloat("Z",Z); INI_WriteInt("Geschwindigkeit",geschwindigkeit);
    INI_WriteInt("Radius",radius);
    INI_Save(); INI_Close();
    new text3dtext[128];
    format(text3dtext,128,"||==========||Blitzer||==========||\nGeschwindigkeit: %d\nRadius: %d\n||==========||Blitzer||==========||",geschwindigkeit,radius);
    Blitzer[blitzerid][bX] = X; Blitzer[blitzerid][bY] = Y; Blitzer[blitzerid][bZ] = Z;
    Blitzer[blitzerid][bGeschwindigkeit] = geschwindigkeit;
    Blitzer[blitzerid][bRadius] = radius;
    Blitzer[blitzerid][bLabel] = Create3DTextLabel(text3dtext,cBlau,X+1,Y+1,Z+1,radius / 2,0);
    Blitzer[blitzerid][bObjekt] = CreateObject(18880,X+1,Y+1,Z-1,0.0,0.0,0.0);
    return 1;
}
stock bLoad(blitzerid)
{
    new bFile[64];
    format(bFile,64,"Blitzer/%d.ini",blitzerid);
    INI_Open(bFile);
    Blitzer[blitzerid][bX] = INI_ReadFloat("X"); Blitzer[blitzerid][bY] = INI_ReadFloat("Y"); Blitzer[blitzerid][bZ] = INI_ReadFloat("Z");
    Blitzer[blitzerid][bGeschwindigkeit] = INI_ReadInt("Geschwindigkeit");
    Blitzer[blitzerid][bRadius] = INI_ReadInt("Radius");
    new text3dtext[128];
    format(text3dtext,128,"||==========||Blitzer||==========||\nGeschwindigkeit: %d\nRadius: %d\n||==========||Blitzer||==========||",Blitzer[blitzerid][bGeschwindigkeit],Blitzer[blitzerid][bRadius]);
    Blitzer[blitzerid][bLabel] = Create3DTextLabel(text3dtext,cBlau,Blitzer[blitzerid][bX]+1,Blitzer[blitzerid][bY]+1,Blitzer[blitzerid][bZ]+1,Blitzer[blitzerid][bRadius] / 2,0);
    Blitzer[blitzerid][bObjekt] = CreateObject(18880,Blitzer[blitzerid][bX]+1,Blitzer[blitzerid][bY]+1,Blitzer[blitzerid][bZ]-1,0.0,0.0,0.0);
    INI_Close();
    return 1;
}
stock GetPlayerSpeed(playerid,bool:kmh)
{
    new Float:Vx,Float:Vy,Float:Vz,Float:rtn;
    if(IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid),Vx,Vy,Vz); else GetPlayerVelocity(playerid,Vx,Vy,Vz);
    rtn = floatsqroot(floatabs(floatpower(Vx + Vy + Vz,2)));
    return kmh?floatround(rtn * 100 * 1.61):floatround(rtn * 100);
}
