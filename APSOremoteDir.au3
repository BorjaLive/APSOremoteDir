#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon.ico
#AutoIt3Wrapper_Outfile=..\APSOremoteDir.exe
#AutoIt3Wrapper_Res_Fileversion=0.0.1
#AutoIt3Wrapper_Res_ProductName=APSOremoteDir
#AutoIt3Wrapper_Res_ProductVersion=0.0.1
#AutoIt3Wrapper_Res_LegalCopyright=B0vE Borja Live
#AutoIt3Wrapper_Res_Language=1034
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Array.au3>
#include <File.au3>
#include <GUIConstantsEx.au3>
#include <GUIConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include "SFTPEx.au3"
#include <Crypt.au3>

Opt("GUIOnEventMode", True)

#Region GUI
$GUI_main = GUICreate("APSOremoteDir", 500, 225)

GUICtrlCreateLabel("Directorio local", 15, 15)
$input_ldir = GUICtrlCreateInput("", 10, 30, 360)
$button_selectLdir = GUICtrlCreateButton("Seleccionar", 380, 25, 110, 35)
GUICtrlCreateLabel("Directorio remoto", 15, 65)
$input_rdir = GUICtrlCreateInput("", 10, 80, 360)

GUICtrlCreateLabel("Servidor", 15, 115)
$input_server = GUICtrlCreateInput("172.17.21.248", 10, 130, 100)
GUICtrlCreateLabel("Puerto", 135, 115)
$input_port = GUICtrlCreateInput("22", 130, 130, 50)
GUICtrlCreateLabel("Usuario", 205, 115)
$input_user = GUICtrlCreateInput("", 200, 130, 150)
GUICtrlCreateLabel("Contraseña", 375, 115)
$input_pass = GUICtrlCreateInput("", 370, 130, 100)

$button_start = GUICtrlCreateButton("Comenzar", 30, 170, 110, 35)
$input_out = GUICtrlCreateInput("Conexión no establecida", 150, 185, 300, 20, $ES_READONLY)

GUICtrlSetOnEvent($button_start, "toggleActive")
GUICtrlSetOnEvent($button_selectLdir, "changeLDIR")
GUISetOnEvent($GUI_EVENT_CLOSE, "salir")
GUISetState(@SW_SHOW, $GUI_main)
#EndRegion

$active = false
Global $hOpen, $hConn, $oDictionary

While True
	Sleep(50)
	if($active) Then act()
WEnd






Func act()
	$files = _FileListToArray(GUICtrlRead($input_ldir), "*", $FLTA_FILES )
	For $i = 1 To $files[0]
		$file = $files[$i]
		$hash = _Crypt_HashFile (GUICtrlRead($input_ldir)&"\"&$file, $CALG_MD5)
		$update = False
		If $oDictionary.Exists($file) Then
			If $oDictionary.Item($file) <> $hash Then
				$update = True
				$oDictionary.Item($file) = $hash
			EndIf
		Else
			$update = True
			$oDictionary.Add ($file, $hash)
		EndIf
		If $update Then
			If _SFTP_FileExists($hConn, $file) Then _SFTP_FileDelete($hConn, $file)
			_SFTP_FilePut($hConn, $file)
			GUICtrlSetData($input_out, "Ultimo fichero actualizado: " & $file)
		EndIf
	Next
EndFunc

Func toggleActive()
	If $active Then
		GUICtrlSetData($button_start, "Comenzar")
		_Crypt_Shutdown()
		_SFTP_Close($hConn)
		_SFTP_Close($hOpen)
		GUICtrlSetData($input_out, "Sincronización detenida")
	Else
		GUICtrlSetData($button_start, "Detener")
		_Crypt_Startup()
		$hOpen = _SFTP_Open()
		$hConn = _SFTP_Connect($hOpen, GUICtrlRead($input_server), GUICtrlRead($input_user), GUICtrlRead($input_pass), GUICtrlRead($input_port))
		_SFTP_DirSetCurrent($hConn, GUICtrlRead($input_rdir))
		_SFTP_DirSetCurrentLocal($hConn, GUICtrlRead($input_ldir))
		$oDictionary = ObjCreate("Scripting.Dictionary")
		GUICtrlSetData($input_out, "Sincronización iniciada")
	EndIf
	$active = not $active
EndFunc
Func changeLDIR()
	GUICtrlSetData($input_ldir, FileSelectFolder("Selecciona el directorio local.", ""))
EndFunc

Func md5($text)
	return $text
EndFunc
Func salir()
	Exit
EndFunc