        TITLE   stubs for Windows API functions
        PAGE    55,132
        .286

; WINAPI.ASM Hooks for Windows 3.1 API
; LMI WinForth 1.0 for Microsoft Windows 3.1
; Copyright 1986-1993 Laboratory Microsystems Inc.
; All Rights Reserved
; 08/16/92 updated for 3.1; stress, OLE, reg database stuff excluded
;          as well as misc C-oriented functions like _hwrite and lstrcat
; 08/17/93 DDE* functions fixed per Dave Ruske
; 09/15/93 MoveWindow return value fixed (void -> bool)
; 09/19/93 CreateDialogIndirectParam fixed per Dave Ruske (7 -> 8)
; 12/26/93 Fix bindings for DDEAccessData, RegisterClass, SetPixel,
;          SetTextColor, SetWindowPos
; 02/26/94 Fix bindings for BitBlt (10 params) and GlobalUnfix (ret. void)
                                
                                ; must be synchronized with winhook.asm
void    =       0               ; no result
single  =       1               ; single-precision result
double  =       2               ; double-precision result       
farptr  =       3               ; far pointer (swapped on stack)
bool    =       4               ; boolean (C=0 or 1, Forth=0 or -1)
hstring =       2

        include winforth.mac
        .xall

        extrn   wintrap:far

FORTH_DATA segment word public 'FAR_DATA'

FORTH_DATA ends

; --------------------------------------------------------------------

winhook macro   hdrname,winfxn,argcount,restype

        extrn   winfxn:far

FORTH_TEXT segment word public 'CODE'

        assume  cs:FORTH_TEXT

        public  @&hdrname
        even
@&hdrname proc  near
        call    wintrap
        dd      winfxn
        db      argcount*2
        db      restype
@&hdrname endp

FORTH_TEXT ends

        header  hdrname,@&hdrname,0

        endm

; --------------------------------------------------------------------

        winhook AbortDoc,ABORTDOC,1,single
        winhook AccessResource,ACCESSRESOURCE,2,single
        winhook AddAtom,ADDATOM,2,single
        winhook AddFontResource,ADDFONTRESOURCE,2,single
        winhook AdjustWindowRect,ADJUSTWINDOWRECT,5,void
        winhook AdjustWindowRectEx,ADJUSTWINDOWRECTEX,7,void
        winhook AllocDStoCSAlias,ALLOCDSTOCSALIAS,1,single
        winhook AllocResource,ALLOCRESOURCE,4,single
        winhook AllocSelector,ALLOCSELECTOR,1,single
        winhook AnimatePalette,ANIMATEPALETTE,5,void
        winhook AnsiLower,ANSILOWER,2,farptr
        winhook AnsiLowerBuff,ANSILOWERBUFF,3,single
        winhook AnsiNext,ANSINEXT,2,farptr
        winhook AnsiPrev,ANSIPREV,4,farptr
        winhook AnsiToOem,ANSITOOEM,4,single
        winhook AnsiToOemBuff,ANSITOOEMBUFF,5,void
        winhook AnsiUpper,ANSIUPPER,2,farptr
        winhook AnsiUpperBuff,ANSIUPPERBUFF,3,single
        winhook AnyPopup,ANYPOPUP,0,bool
        winhook AppendMenu,APPENDMENU,5,bool
        winhook Arc,ARC,9,bool
        winhook ArrangeIconicWindows,ARRANGEICONICWINDOWS,1,single
        winhook BeginDeferWindowPos,BEGINDEFERWINDOWPOS,1,single
        winhook BeginPaint,BEGINPAINT,3,single
        winhook BitBlt,BITBLT,10,bool  ; *** fixed 2/26/94
        winhook BringWindowToTop,BRINGWINDOWTOTOP,1,void
        winhook BuildCommDCB,BUILDCOMMDCB,4,single
        winhook CallMsgFilter,CALLMSGFILTER,3,bool
        winhook CallWindowProc,CALLWINDOWPROC,6,double
        winhook Catch,CATCH,2,single
        winhook ChangeClipboardChain,CHANGECLIPBOARDCHAIN,2,bool
;       winhook ChangeMenu
;       winhook ChangeSelector,CHANGESELECTOR,2,single
        winhook CheckDlgButton,CHECKDLGBUTTON,3,void
        winhook CheckMenuItem,CHECKMENUITEM,3,bool
        winhook CheckRadioButton,CHECKRADIOBUTTON,4,void
        winhook ChildWindowFromPoint,CHILDWINDOWFROMPOINT,3,single
        winhook ChooseColor,CHOOSECOLOR,2,bool          ; 3.1
        winhook ChooseFont,CHOOSEFONT,2,bool            ; 3.1
        winhook Chord,CHORD,9,bool
        winhook ClassFirst,CLASSFIRST,2, bool           ; 3.1
        winhook ClassNext,CLASSNEXT,2,bool              ; 3.1
        winhook ClearCommBreak,CLEARCOMMBREAK,1,single
        winhook ClientToScreen,CLIENTTOSCREEN,3,void
        winhook ClipCursor,CLIPCURSOR,2,void
        winhook CloseClipboard,CLOSECLIPBOARD,0,bool
        winhook CloseComm,CLOSECOMM,1,single
        winhook CloseMetaFile,CLOSEMETAFILE,1,single
        winhook CloseSound,CLOSESOUND,0,void
        winhook CloseWindow,CLOSEWINDOW,1,void
        winhook CombineRgn,COMBINERGN,4,single
        winhook CommDlgExtendedError,COMMDLGEXTENDEDERROR,0,double ; 3.1
        winhook CopyCursor,COPYCURSOR,2,single                  ; 3.1
        winhook CopyIcon,COPYICON,2,single                      ; 3.1
;       winhook CopyLZFile,COPYLZFILE,2,double                  ; 3.1
        winhook CopyMetaFile,COPYMETAFILE,3,single
        winhook CopyRect,COPYRECT,4,single
        winhook CountClipboardFormats,COUNTCLIPBOARDFORMATS,0,single
        winhook CountVoiceNotes,COUNTVOICENOTES,1,single
        winhook CreateBitmap,CREATEBITMAP,6,single
        winhook CreateBitmapIndirect,CREATEBITMAPINDIRECT,2,single
        winhook CreateBrushIndirect,CREATEBRUSHINDIRECT,2,single
        winhook CreateCaret,CREATECARET,4,void
        winhook CreateCompatibleBitmap,CREATECOMPATIBLEBITMAP,3,single
        winhook CreateCompatibleDC,CREATECOMPATIBLEDC,1,single
        winhook CreateCursor,CREATECURSOR,9,single
        winhook CreateDC,CREATEDC,8,single
        winhook CreateDialog,CREATEDIALOG,6,single
        winhook CreateDialogIndirect,CREATEDIALOGINDIRECT,6,single
        winhook CreateDialogIndirectParam,CREATEDIALOGINDIRECTPARAM,8,single ; * fixed 9/19/93
        winhook CreateDialogParam,CREATEDIALOGPARAM,8,single
        winhook CreateDIBitmap,CREATEDIBITMAP,9,single
;       winhook CreateDIPatternBrush,CREATEDIPATTERNBRUSH,2,single
        winhook CreateDiscardableBitmap,CREATEDISCARDABLEBITMAP,3,single
        winhook CreateEllipticRgn,CREATEELLIPTICRGN,4,single
        winhook CreateEllipticRgnIndirect,CREATEELLIPTICRGNINDIRECT,2,single
        winhook CreateFont,CREATEFONT,15,single
        winhook CreateFontIndirect,CREATEFONTINDIRECT,2,single
        winhook CreateHatchBrush,CREATEHATCHBRUSH,2,single
        winhook CreateIC,CREATEIC,8,single
        winhook CreateIcon,CREATEICON,9,single
        winhook CreateMenu,CREATEMENU,0,single
        winhook CreateMetaFile,CREATEMETAFILE,2,single
        winhook CreatePalette,CREATEPALETTE,2,single
        winhook CreatePatternBrush,CREATEPATTERNBRUSH,1,single
        winhook CreatePen,CREATEPEN,3,single
        winhook CreatePenIndirect,CREATEPENINDIRECT,2,single
        winhook CreatePolygonRgn,CREATEPOLYGONRGN,4,single
        winhook CreatePolyPolygonRgn,CREATEPOLYPOLYGONRGN,6,single
        winhook CreatePopupMenu,CREATEPOPUPMENU,0,single
        winhook CreateRectRgn,CREATERECTRGN,4,single
        winhook CreateRectRgnIndirect,CREATERECTRGNINDIRECT,2,single
        winhook CreateRoundRectRgn,CREATEROUNDRECTRGN,6,single
;       winhook CreateScalableFontResource
        winhook CreateSolidBrush,CREATESOLIDBRUSH,1,single
        winhook CreateWindow,CREATEWINDOW,15,single
        winhook CreateWindowEx,CREATEWINDOWEX,17,single
        winhook DdeAbandonTransaction,DDEABANDONTRANSACTION,6,bool  ; 3.1
        winhook DdeAccessData,DDEACCESSDATA,4,farptr                ; 3.1
        winhook DdeAddData,DDEADDDATA,8,double                      ; 3.1
        winhook DdeClientTransaction,DDECLIENTTRANSACTION,14,double ; 3.1
        winhook DdeCmpStringHandles,DDECMPSTRINGHANDLES,4,single    ; 3.1
        winhook DdeConnect,DDECONNECT,8,double                      ; 3.1
        winhook DdeConnectList,DDECONNECTLIST,10,double             ; 3.1
        winhook DdeCreateDataHandle,DDECREATEDATAHANDLE,12,double   ; 3.1
        winhook DdeCreateStringHandle,DDECREATESTRINGHANDLE,5,double ; 3.1
        winhook DdeDisconnect,DDEDISCONNECT,2,bool                  ; 3.1
        winhook DdeDisconnectList,DDEDISCONNECTLIST,2,bool          ; 3.1
        winhook DdeEnableCallback,DDEENABLECALLBACK,5,bool          ; 3.1
        winhook DdeFreeDataHandle,DDEFREEDATAHANDLE,2,bool          ; 3.1
        winhook DdeFreeStringHandle,DDEFREESTRINGHANDLE,4,bool      ; 3.1
        winhook DdeGetData,DDEGETDATA,8,double                      ; 3.1
        winhook DdeGetLastError,DDEGETLASTERROR,2,single            ; 3.1                      ; 3.1
        winhook DdeInitialize,DDEINITIALIZE,8,single                ; 3.1
        winhook DdeKeepStringHandle,DDEKEEPSTRINGHANDLE,4,bool      ; 3.1
        winhook DdeNameService,DDENAMESERVICE,7,double              ; 3.1
        winhook DdePostAdvise,DDEPOSTADVISE,6,bool                  ; 3.1
        winhook DdeQueryConvInfo,DDEQUERYCONVINFO,6,single          ; 3.1
        winhook DdeQueryNextServer,DDEQUERYNEXTSERVER,4,double      ; 3.1
        winhook DdeQueryString,DDEQUERYSTRING,9,double              ; 3.1
        winhook DdeReconnect,DDERECONNECT,2,double                  ; 3.1
        winhook DdeSetUserHandle,DDESETUSERHANDLE,6,bool            ; 3.1
        winhook DdeUnaccessData,DDEUNACCESSDATA,2,bool              ; 3.1
        winhook DdeUninitialize,DDEUNINITIALIZE,2,bool              ; 3.1
        winhook DefDlgProc,DEFDLGPROC,5,double
        winhook DeferWindowPos,DEFERWINDOWPOS,8,single
        winhook DefFrameProc,DEFFRAMEPROC,6,double
        winhook DefHookProc,DEFHOOKPROC,6,double
        winhook DefineHandleTable,DEFINEHANDLETABLE,1,bool
        winhook DefMDIChildProc,DEFMDICHILDPROC,5,double
        winhook DefWindowProc,DEFWINDOWPROC,5,double
        winhook DeleteAtom,DELETEATOM,1,single
        winhook DeleteDC,DELETEDC,1,bool
        winhook DeleteMenu,DELETEMENU,3,bool
        winhook DeleteMetaFile,DELETEMETAFILE,1,bool
        winhook DeleteObject,DELETEOBJECT,1,bool
        winhook DestroyCaret,DESTROYCARET,0,void
        winhook DestroyCursor,DESTROYCURSOR,1,bool
        winhook DestroyIcon,DESTROYICON,1,bool
        winhook DestroyMenu,DESTROYMENU,1,bool
        winhook DestroyWindow,DESTROYWINDOW,1,bool
;       winhook DeviceCapabilities,DEVICECAPABILITIES,9,double
;       winhook DeviceMode,DEVICEMODE,6,void
        winhook DialogBox,DIALOGBOX,6,single
        winhook DialogBoxIndirect,DIALOGBOXINDIRECT,5,single
        winhook DialogBoxIndirectParam,DIALOGBOXINDIRECTPARAM,7,single
        winhook DialogBoxParam,DIALOGBOXPARAM,8,single
        winhook DirectedYield,DIRECTEDYIELD,1,void              ; 3.1
        winhook DispatchMessage,DISPATCHMESSAGE,2,double
        winhook DlgDirList,DLGDIRLIST,6,single
        winhook DlgDirListComboBox,DLGDIRLISTCOMBOBOX,6,single
        winhook DlgDirSelect,DLGDIRSELECT,4,bool
        winhook DlgDirSelectComboBox,DLGDIRSELECTCOMBOBOX,4,bool
        winhook DlgDirSelectComboBoxEx,DLGDIRSELECTCOMBOBOXEX,5,bool  ; 3.1
        winhook DlgDirSelectEx,DLGDIRSELECTEX,5,bool            ; 3.1
        winhook DPtoLP,DPTOLP,4,bool
        winhook DragAcceptFiles,DRAGACCEPTFILES,2,void          ; 3.1
        winhook DragFinish,DRAGFINISH,1,void                    ; 3.1
        winhook DragQueryFile,DRAGQUERYFILE,5,single            ; 3.1
        winhook DragQueryPoint,DRAGQUERYPOINT,3,bool            ; 3.1
        winhook DrawFocusRect,DRAWFOCUSRECT,3,void
        winhook DrawIcon,DRAWICON,4,bool
        winhook DrawMenuBar,DRAWMENUBAR,1,void
        winhook DrawText,DRAWTEXT,7,single
        winhook Ellipse,ELLIPSE,4,bool
        winhook EmptyClipboard,EMPTYCLIPBOARD,0,bool
        winhook EnableCommNotification,ENABLECOMMNOTIFICATION,4,bool    ; 3.1
        winhook EnableHardwareInput,ENABLEHARDWAREINPUT,1,bool
        winhook EnableMenuItem,ENABLEMENUITEM,3,bool
        winhook EnableScrollBar,ENABLESCROLLBAR,3,bool          ; 3.1
        winhook EnableWindow,ENABLEWINDOW,2,bool
        winhook EndDeferWindowPos,ENDDEFERWINDOWPOS,1,void
        winhook EndDialog,ENDDIALOG,2,void
        winhook EndDoc,ENDDOC,1,single                          ; 3.1
        winhook EndPage,ENDPAGE,1,single                        ; 3.1
        winhook EndPaint,ENDPAINT,3,void
        winhook EnumChildWindows,ENUMCHILDWINDOWS,5,bool
        winhook EnumClipboardFormats,ENUMCLIPBOARDFORMATS,1,single
        winhook EnumFontFamilies,ENUMFONTFAMILIES,7,single      ; 3.1
        winhook EnumFonts,ENUMFONTS,7,single
        winhook EnumMetaFile,ENUMMETAFILE,6,bool
        winhook EnumObjects,ENUMOBJECTS,6,single
        winhook EnumProps,ENUMPROPS,3,single
        winhook EnumTaskWindows,ENUMTASKWINDOWS,5,bool
        winhook EnumWindows,ENUMWINDOWS,4,bool
        winhook EqualRect,EQUALRECT,4,bool
        winhook EqualRgn,EQUALRGN,2,bool
        winhook Escape,ESCAPE,7,single
        winhook EscapeCommFunction,ESCAPECOMMFUNCTION,2,double
        winhook ExcludeClipRect,EXCLUDECLIPRECT,5,single
        winhook ExcludeUpdateRgn,EXCLUDEUPDATERGN,2,single
        winhook ExitWindows,EXITWINDOWS,3,bool
        winhook ExitWindowsExec,EXITWINDOWSEXEC,4,bool          ; 3.1
;       winhook ExtDeviceMode,EXTDEVICEMODE,13,single
        winhook ExtFloodFill,EXTFLOODFILL,5,bool
        winhook ExtractIcon,EXTRACTICON,4,single                ; 3.1
        winhook ExtTextOut,EXTTEXTOUT,11,bool
        winhook FatalAppExit,FATALAPPEXIT,3,void
        winhook FatalExit,FATALEXIT,1,void
        winhook FillRect,FILLRECT,4,single
        winhook FillRgn,FILLRGN,3,bool
        winhook FindAtom,FINDATOM,2,single
        winhook FindExecutable,FINDEXECUTABLE,6,single          ; 3.1
        winhook FindResource,FINDRESOURCE,5,single
        winhook FindText,FINDTEXT,2,single                      ; 3.1
        winhook FindWindow,FINDWINDOW,4,single
        winhook FlashWindow,FLASHWINDOW,2,bool
        winhook FloodFill,FLOODFILL,4,bool
        winhook FlushComm,FLUSHCOMM,2,single
        winhook FrameRect,FRAMERECT,4,single
        winhook FrameRgn,FRAMERGN,5,bool
        winhook FreeLibrary,FREELIBRARY,1,void
        winhook FreeModule,FREEMODULE,1,void
        winhook FreeProcInstance,FREEPROCINSTANCE,2,void
        winhook FreeResource,FREERESOURCE,1,bool
        winhook FreeSelector,FREESELECTOR,1,single
        winhook GetActiveWindow,GETACTIVEWINDOW,0,single
        winhook GetAspectRatioFilter,GETASPECTRATIOFILTER,1,double
        winhook GetAspectRatioFilterEx,GETASPECTRATIOFILTEREX,3,single ; 3.1
        winhook GetAsyncKeyState,GETASYNCKEYSTATE,1,single
        winhook GetAtomHandle,GETATOMHANDLE,1,single
        winhook GetAtomName,GETATOMNAME,4,single
        winhook GetBitmapBits,GETBITMAPBITS,5,double
        winhook GetBitmapDimension,GETBITMAPDIMENSION,1,double
        winhook GetBitmapDimensionEx,GETBITMAPDIMENSIONEX,3,bool    ; 3.1
        winhook GetBkColor,GETBKCOLOR,1,double
        winhook GetBkMode,GETBKMODE,1,single
        winhook GetBoundsRect,GETBOUNDSRECT,4,single            ; 3.1
        winhook GetBrushOrg,GETBRUSHORG,1,double
        winhook GetBrushOrgEx,GETBRUSHORGEX,3,bool              ; 3.1
        winhook GetCapture,GETCAPTURE,0,single
        winhook GetCaretBlinkTime,GETCARETBLINKTIME,0,single
        winhook GetCaretPos,GETCARETPOS,2,void
        winhook GetCharABCWidths,GETCHARABCWIDTHS,5,bool        ; 3.1   
        winhook GetCharWidth,GETCHARWIDTH,5,bool
        winhook GetClassInfo,GETCLASSINFO,5,bool
        winhook GetClassLong,GETCLASSLONG,2,double
        winhook GetClassName,GETCLASSNAME,4,single
        winhook GetClassWord,GETCLASSWORD,2,single
        winhook GetClientRect,GETCLIENTRECT,3,void
        winhook GetClipboardData,GETCLIPBOARDDATA,1,single
        winhook GetClipboardFormatName,GETCLIPBOARDFORMATNAME,4,single
        winhook GetClipboardOwner,GETCLIPBOARDOWNER,0,single
        winhook GetClipBox,GETCLIPBOX,3,single
        winhook GetClipCursor,GETCLIPCURSOR,2,void              ; 3.1
        winhook GetCodeHandle,GETCODEHANDLE,2,single
        winhook GetCodeInfo,GETCODEINFO,4,void
        winhook GetCommError,GETCOMMERROR,3,single
        winhook GetCommEventMask,GETCOMMEVENTMASK,2,single
        winhook GetCommState,GETCOMMSTATE,3,single
        winhook GetCurrentPDB,GETCURRENTPDB,0,single
        winhook GetCurrentPosition,GETCURRENTPOSITION,1,double
        winhook GetCurrentPositionEx,GETCURRENTPOSITIONEX,3,bool  ; 3.1
        winhook GetCurrentTask,GETCURRENTTASK,0,single
        winhook GetCurrentTime,GETCURRENTTIME,0,double
        winhook GetCursor,GETCURSOR,0,single                    ; 3.1
        winhook GetCursorPos,GETCURSORPOS,2,void
        winhook GetDC,GETDC,1,single
        winhook GetDCEx,GETDCEX,4,single
        winhook GetDCOrg,GETDCORG,1,double
        winhook GetDesktopWindow,GETDESKTOPWINDOW,0,single
        winhook GetDeviceCaps,GETDEVICECAPS,2,single
        winhook GetDialogBaseUnits,GETDIALOGBASEUNITS,0,double
        winhook GetDIBits,GETDIBITS,9,single
        winhook GetDlgCtrlID,GETDLGCTRLID,1,single
        winhook GetDlgItem,GETDLGITEM,2,single
        winhook GetDlgItemInt,GETDLGITEMINT,5,single
        winhook GetDlgItemText,GETDLGITEMTEXT,5,single
        winhook GetDOSEnvironment,GETDOSENVIRONMENT,0,farptr
        winhook GetDoubleClickTime,GETDOUBLECLICKTIME,0,single
;       winhook GetDriverInfo                                   ; 3.1
;       winhook GetDriverModuleHandle                           ; 3.1
        winhook GetDriveType,GETDRIVETYPE,1,single
        winhook GetEnvironment,GETENVIRONMENT,5,single
        winhook GetExpandedName,GETEXPANDEDNAME,4,single        ; 3.1
        winhook GetFileResource,GETFILERESOURCE,12,bool         ; 3.1
        winhook GetFileResourceSize,GETFILERESOURCESIZE,10,double ; 3.1
        winhook GetFileTitle,GETFILETITLE,5,single              ; 3.1
        winhook GetFileVersionInfo,GETFILEVERSIONINFO,8,bool    ; 3.1
        winhook GetFileVersionInfoSize,GETFILEVERSIONINFOSIZE,4,double ; 3.1
        winhook GetFocus,GETFOCUS,0,single
        winhook GetFontData,GETFONTDATA,9,double                ; 3.1
        winhook GetFreeSpace,GETFREESPACE,1,double
        winhook GetFreeSystemResources,GETFREESYSTEMRESOURCES,1,single ; 3.1
        winhook GetGlyphOutline,GETGLYPHOUTLINE,11,double       ; 3.1
        winhook GetInputState,GETINPUTSTATE,0,bool
        winhook GetInstanceData,GETINSTANCEDATA,3,single
        winhook GetKBCodePage,GETKBCODEPAGE,0,single
        winhook GetKerningPairs,GETKERNINGPAIRS,4,single        ; 3.1
        winhook GetKeyboardState,GETKEYBOARDSTATE,2,void
        winhook GetKeyboardType,GETKEYBOARDTYPE,1,single
        winhook GetKeyNameText,GETKEYNAMETEXT,5,single
        winhook GetKeyState,GETKEYSTATE,1,single
        winhook GetLastActivePopup,GETLASTACTIVEPOPUP,1,single
        winhook GetMapMode,GETMAPMODE,1,single
        winhook GetMenu,GETMENU,1,single
        winhook GetMenuCheckMarkDimensions,GETMENUCHECKMARKDIMENSIONS,0,double
        winhook GetMenuItemCount,GETMENUITEMCOUNT,1,single
        winhook GetMenuItemID,GETMENUITEMID,2,single
        winhook GetMenuState,GETMENUSTATE,3,single
        winhook GetMenuString,GETMENUSTRING,6,single
        winhook GetMessage,GETMESSAGE,5,bool
        winhook GetMessageExtraInfo,GETMESSAGEEXTRAINFO,0,double  ; 3.1
        winhook GetMessagePos,GETMESSAGEPOS,0,double
        winhook GetMessageTime,GETMESSAGETIME,0,double
        winhook GetMetaFile,GETMETAFILE,2,single
        winhook GetMetaFileBits,GETMETAFILEBITS,1,single
        winhook GetModuleFileName,GETMODULEFILENAME,4,single
        winhook GetModuleHandle,GETMODULEHANDLE,2,single
        winhook GetModuleUsage,GETMODULEUSAGE,1,single
        winhook GetNearestColor,GETNEARESTCOLOR,3,double        ; 3.1
        winhook GetNearestPaletteIndex,GETNEARESTPALETTEINDEX,2,single
        winhook GetNextDlgGroupItem,GETNEXTDLGGROUPITEM,3,single
        winhook GetNextDlgTabItem,GETNEXTDLGTABITEM,3,single
;       winhook GetNextDriver                                   ; 3.1
        winhook GetNextWindow,GETNEXTWINDOW,2,single
        winhook GetNumTasks,GETNUMTASKS,0,single
        winhook GetObject,GETOBJECT,4,single
        winhook GetOpenClipboardWindow,GETOPENCLIPBOARDWINDOW,2,bool ; 3.1
        winhook GetOpenFileName,GETOPENFILENAME,2,bool  ; 3.1
        winhook GetOutlineTextMetrics,GETOUTLINETEXTMETRICS,4,single ; 3.1
        winhook GetPaletteEntries,GETPALETTEENTRIES,5,single
        winhook GetParent,GETPARENT,1,single
        winhook GetPixel,GETPIXEL,3,double
        winhook GetPolyFillMode,GETPOLYFILLMODE,1,single
        winhook GetPriorityClipboardFormat,GETPRIORITYCLIPBOARDFORMAT,3,single
        winhook GetPrivateProfileInt,GETPRIVATEPROFILEINT,7,single
        winhook GetPrivateProfileString,GETPRIVATEPROFILESTRING,11,single
        winhook GetProcAddress,GETPROCADDRESS,3,farptr
        winhook GetProfileInt,GETPROFILEINT,5,single
        winhook GetProfileString,GETPROFILESTRING,9,single
        winhook GetProp,GETPROP,3,single
        winhook GetQueueStatus,GETQUEUESTATUS,1,double          ; 3.1
        winhook GetRasterizerCaps,GETRASTERIZERCAPS,3,bool      ; 3.1
        winhook GetRgnBox,GETRGNBOX,3,single
        winhook GetROP2,GETROP2,1,single
        winhook GetSaveFileName,GETSAVEFILENAME,2,bool          ; 3.1
        winhook GetScrollPos,GETSCROLLPOS,2,single
        winhook GetScrollRange,GETSCROLLRANGE,6,void
        winhook GetSelectorBase,GETSELECTORBASE,1,double        ; 3.1
        winhook GetSelectorLimit,GETSELECTORLIMIT,1,double      ; 3.1
        winhook GetStockObject,GETSTOCKOBJECT,1,single
        winhook GetStretchBltMode,GETSTRETCHBLTMODE,1,single
        winhook GetSubMenu,GETSUBMENU,2,single
        winhook GetSysColor,GETSYSCOLOR,1,double
        winhook GetSysModalWindow,GETSYSMODALWINDOW,0,single    ; 3.1
;       winhook GetSystemDebugState                             ; 3.1
;       winhook GetSystemDir,GETSYSTEMDIR,5,single              ; 3.1
        winhook GetSystemDirectory,GETSYSTEMDIRECTORY,3,single
        winhook GetSystemMenu,GETSYSTEMMENU,2,single
        winhook GetSystemMetrics,GETSYSTEMMETRICS,1,single
        winhook GetSystemPaletteEntries,GETSYSTEMPALETTEENTRIES,5,single
        winhook GetSystemPaletteUse,GETSYSTEMPALETTEUSE,1,single
        winhook GetTabbedTextExtent,GETTABBEDTEXTEXTENT,7,double
        winhook GetTempDrive,GETTEMPDRIVE,1,single
        winhook GetTempFileName,GETTEMPFILENAME,6,single
        winhook GetTextAlign,GETTEXTALIGN,1,single
        winhook GetTextCharacterExtra,GETTEXTCHARACTEREXTRA,1,single
        winhook GetTextColor,GETTEXTCOLOR,1,double
        winhook GetTextExtent,GETTEXTEXTENT,4,double
        winhook GetTextExtentPoint,GETTEXTEXTENTPOINT,6,bool    ; 3.1
        winhook GetTextFace,GETTEXTFACE,4,single
        winhook GetTextMetrics,GETTEXTMETRICS,3,bool
        winhook GetThresholdEvent,GETTHRESHOLDEVENT,0,farptr
        winhook GetThresholdStatus,GETTHRESHOLDSTATUS,0,single
        winhook GetTickCount,GETTICKCOUNT,0,double
        winhook GetTimerResolution,GETTIMERRESOLUTION,0,double  ; 3.1
        winhook GetTopWindow,GETTOPWINDOW,1,single
        winhook GetUpdateRect,GETUPDATERECT,4,bool
        winhook GetUpdateRgn,GETUPDATERGN,3,single
        winhook GetVersion,GETVERSION,0,double
        winhook GetViewportExt,GETVIEWPORTEXT,1,double
        winhook GetViewportExtEx,GETVIEWPORTEXTEX,3,bool        ; 3.1
        winhook GetViewportOrg,GETVIEWPORTORG,1,double
        winhook GetViewportOrgEx,GETVIEWPORTORGEX,3,bool        ; 3.1
;       winhook GetWinDebugInfo                                 ; 3.1
        winhook GetWindow,GETWINDOW,2,single
        winhook GetWindowDC,GETWINDOWDC,1,single
        winhook GetWindowExt,GETWINDOWEXT,1,double
        winhook GetWindowExtEx,GETWINDOWEXTEX,3,bool            ; 3.1
        winhook GetWindowLong,GETWINDOWLONG,2,double
        winhook GetWindowOrg,GETWINDOWORG,1,double
        winhook GetWindowOrgEx,GETWINDOWORGEX,3,bool
        winhook GetWindowPlacement,GETWINDOWPLACEMENT,3,bool    ; 3.1
        winhook GetWindowRect,GETWINDOWRECT,3,void
;       winhook GetWindowsDir                                   ; 3.1
        winhook GetWindowsDirectory,GETWINDOWSDIRECTORY,3,single
        winhook GetWindowTask,GETWINDOWTASK,1,single
        winhook GetWindowText,GETWINDOWTEXT,4,single
        winhook GetWindowTextLength,GETWINDOWTEXTLENGTH,1,single
        winhook GetWindowWord,GETWINDOWWORD,2,single
        winhook GetWinFlags,GETWINFLAGS,0,double
        winhook GlobalAddAtom,GLOBALADDATOM,2,single
        winhook GlobalAlloc,GLOBALALLOC,3,single
        winhook GlobalCompact,GLOBALCOMPACT,2,double
        winhook GlobalDeleteAtom,GLOBALDELETEATOM,1,single
        winhook GlobalDosAlloc,GLOBALDOSALLOC,2,double
        winhook GlobalDosFree,GLOBALDOSFREE,1,single
        winhook GlobalEntryHandle,GLOBALENTRYHANDLE,3,bool      ; 3.1
        winhook GlobalEntryModule,GLOBALENTRYMODULE,4,bool      ; 3.1
        winhook GlobalFindAtom,GLOBALFINDATOM,2,single
        winhook GlobalFirst,GLOBALFIRST,3,bool                  ; 3.1
        winhook GlobalFix,GLOBALFIX,1,void
        winhook GlobalFlags,GLOBALFLAGS,1,single
        winhook GlobalFree,GLOBALFREE,1,single
        winhook GlobalGetAtomName,GLOBALGETATOMNAME,4,single
        winhook GlobalHandle,GLOBALHANDLE,1,double
        winhook GlobalHandleToSel,GLOBALHANDLETOSEL,1,single    ; 3.1
        winhook GlobalInfo,GLOBALINFO,2,bool                    ; 3.1
        winhook GlobalLock,GLOBALLOCK,1,farptr
        winhook GlobalLRUNewest,GLOBALLRUNEWEST,1,single
        winhook GlobalLRUOldest,GLOBALLRUOLDEST,1,single
        winhook GlobalNext,GLOBALNEXT,3,bool                    ; 3.1
        winhook GlobalNotify,GLOBALNOTIFY,2,void
        winhook GlobalPageLock,GLOBALPAGELOCK,1,single
        winhook GlobalPageUnlock,GLOBALPAGEUNLOCK,1,single
        winhook GlobalReAlloc,GLOBALREALLOC,4,single
        winhook GlobalSize,GLOBALSIZE,1,double
        winhook GlobalUnfix,GLOBALUNFIX,1,void  ; *** fixed 2/26/94
        winhook GlobalUnlock,GLOBALUNLOCK,1,bool
;       winhook GlobalUnWire,GLOBALUNWIRE,1,bool        ; obs in 3.1
;       winhook GlobalWire,GLOBALWIRE,1,farptr          ; obs in 3.1
        winhook GrayString,GRAYSTRING,11,bool
        winhook HideCaret,HIDECARET,1,void
        winhook HiliteMenuItem,HILITEMENUITEM,4,bool    ; *** bool after here
;       winhook hmemcpy                                 ; 3.1 for C
;       winhook _hread                                  ; 3.1 for C
;       winhook _hwrite                                 ; 3.1 for C
        winhook InflateRect,INFLATERECT,4,void
        winhook InitAtomTable,INITATOMTABLE,1,bool
        winhook InSendMessage,INSENDMESSAGE,0,bool
        winhook InsertMenu,INSERTMENU,6,bool
;       winhook InterruptRegister                       ; 3.1
;       winhook InterruptUnRegister                     ; 3.1
        winhook IntersectClipRect,INTERSECTCLIPRECT,5,single
        winhook IntersectRect,INTERSECTRECT,6,single
        winhook InvalidateRect,INVALIDATERECT,4,void
        winhook InvalidateRgn,INVALIDATERGN,3,void
        winhook InvertRect,INVERTRECT,3,void
        winhook InvertRgn,INVERTRGN,2,bool
        winhook IsBadCodePtr,ISBADCODEPTR,2,bool                ; 3.1
;       winhook IsBadHugeReadPtr                                ; 3.1
;       winhook IsBadHugeWritePtr                               ; 3.1
        winhook IsBadReadPtr,ISBADREADPTR,3,bool                ; 3.1
        winhook IsBadStringPtr,ISBADSTRINGPTR,3,bool            ; 3.1
        winhook IsBadWriterPtr,ISBADWRITEPTR,3,bool             ; 3.1
        winhook IsCharAlpha,ISCHARALPHA,1,bool
        winhook IsCharAlphaNumeric,ISCHARALPHANUMERIC,1,bool
        winhook IsCharLower,ISCHARLOWER,1,bool
        winhook IsCharUpper,ISCHARUPPER,1,bool
        winhook IsChild,ISCHILD,2,bool
        winhook IsClipboardFormatAvailable,ISCLIPBOARDFORMATAVAILABLE,1,bool
;       winhook IsDBCSLeadByte                                  ; 3.1
        winhook IsDialogMessage,ISDIALOGMESSAGE,3,bool
        winhook IsDlgButtonChecked,ISDLGBUTTONCHECKED,2,single
        winhook IsGDIObject,ISGDIOBJECT,1,bool                  ; 3.1
        winhook IsIconic,ISICONIC,1,bool
        winhook IsMenu,ISMENU,1,bool                            ; 3.1
        winhook IsRectEmpty,ISRECTEMPTY,2,bool
        winhook IsTask,ISTASK,1,bool                            ; 3.1
        winhook IsWindow,ISWINDOW,1,bool
        winhook IsWindowEnabled,ISWINDOWENABLED,1,bool
        winhook IsWindowVisible,ISWINDOWVISIBLE,1,bool
        winhook IsZoomed,ISZOOMED,1,bool
        winhook KillTimer,KILLTIMER,2,bool
;       winhook LimitEMSPages                           ; obs in 3.1
        winhook LineDDA,LINEDDA,8,void
        winhook LineTo,LINETO,3,bool
        winhook LoadAccelerators,LOADACCELERATORS,3,single
        winhook LoadBitmap,LOADBITMAP,3,single
        winhook LoadCursor,LOADCURSOR,3,single
        winhook LoadIcon,LOADICON,3,single
        winhook LoadLibrary,LOADLIBRARY,2,single
        winhook LoadMenu,LOADMENU,3,single
        winhook LoadMenuIndirect,LOADMENUINDIRECT,2,single
        winhook LoadModule,LOADMODULE,4,single
        winhook LoadResource,LOADRESOURCE,2,single
        winhook LoadString,LOADSTRING,5,single
        winhook LocalAlloc,LOCALALLOC,2,single
        winhook LocalCompact,LOCALCOMPACT,1,single
        winhook LocalFirst,LOCALFIRST,3,bool            ; 3.1
        winhook LocalFlags,LOCALFLAGS,1,single
        winhook LocalFree,LOCALFREE,1,single
        winhook LocalHandle,LOCALHANDLE,1,single
        winhook LocalInfo,LOCALINFO,3,bool              ; 3.1
        winhook LocalInit,LOCALINIT,3,bool
        winhook LocalLock,LOCALLOCK,1,single            ; ** fixed 1/23/92 **
        winhook LocalNext,LOCALNEXT,2,bool              ; 3.1
        winhook LocalReAlloc,LOCALREALLOC,3,single
        winhook LocalShrink,LOCALSHRINK,2,single
        winhook LocalSize,LOCALSIZE,1,single
        winhook LocalUnlock,LOCALUNLOCK,1,bool
        winhook LockInput,LOCKINPUT,3,bool              ; 3.1
        winhook LockResource,LOCKRESOURCE,1,farptr
        winhook LockSegment,LOCKSEGMENT,1,single
        winhook LockWindowUpdate,LOCKWINDOWUPDATE,1,bool        ; 3.1
        winhook LPtoDP,LPTODP,4,bool
        winhook LZClose,LZCLOSE,1,void                  ; 3.1
        winhook LZCopy,LZCOPY,2,double                  ; 3.1
        winhook LZDone,LZDONE,0,void                    ; 3.1
        winhook LZInit,LZINIT,1,single                  ; 3.1
        winhook LZOpenFile,LZOPENFILE,5,single          ; 3.1
        winhook LZRead,LZREAD,4,single                  ; 3.1
        winhook LZSeek,LZSEEK,4,double                  ; 3.1
        winhook LZStart,LZSTART,0,single                ; 3.1
        winhook MakeProcInstance,MAKEPROCINSTANCE,3,farptr
        winhook MapDialogRect,MAPDIALOGRECT,3,void
        winhook MapVirtualKey,MAPVIRTUALKEY,2,single
        winhook MapWindowPoints,MAPWINDOWPOINTS,5,void  ; 3.1
        winhook MemManInfo,MEMMANINFO,2,bool            ; 3.1
        winhook MemoryRead,MEMORYREAD,7,double          ; 3.1
        winhook MemoryWrite,MEMORYWRITE,7,double                ; 3.1
        winhook MessageBeep,MESSAGEBEEP,1,void
        winhook MessageBox,MESSAGEBOX,6,single
        winhook ModifyMenu,MODIFYMENU,6,bool
        winhook ModuleFindHandle,MODULEFINDHANDLE,3,single      ; 3.1
        winhook ModuleFindName,MODULEFINDNAME,4,single          ; 3.1
        winhook ModuleFirst,MODULEFIRST,2,bool                  ; 3.1
        winhook ModuleNext,MODULENEXT,2,bool                    ; 3.1
        winhook MoveTo,MOVETO,3,double
        winhook MoveToEx,MOVETOEX,5,bool                        ; 3.1
        winhook MoveWindow,MOVEWINDOW,6,bool                    ; * chg 3.1
;       winhook NotifyRegister                                  ; 3.1
;       winhook NotifyUnRegister                                ; 3.1
;       winhook OemKeyScan
        winhook OemToAnsi,OEMTOANSI,4,single
        winhook OemToAnsiBuff,OEMTOANSIBUFF,5,void
        winhook OffsetClipRgn,OFFSETCLIPRGN,3,single
        winhook OffsetRect,OFFSETRECT,4,void
        winhook OffsetRgn,OFFSETRGN,3,single
        winhook OffsetViewportOrg,OFFSETVIEWPORTORG,3,double
        winhook OffsetViewportOrgEx,OFFSETVIEWPORTORGEX,5,bool  ; 3.1
        winhook OffsetWindowOrg,OFFSETWINDOWORG,3,double
        winhook OffsetWindowOrgEx,OFFSETWINDOWORGEX,5,bool      ; 3.1
        winhook OpenClipboard,OPENCLIPBOARD,1,bool
        winhook OpenComm,OPENCOMM,4,single
;       winhook OpenDriver                                      ; 3.1
        winhook OpenFile,OPENFILE,5,single
        winhook OpenIcon,OPENICON,1,bool
        winhook OpenSound,OPENSOUND,0,single
;       winhook OutputDebugString
        winhook PaintRgn,PAINTRGN,2,bool
        winhook PatBlt,PATBLT,7,bool
        winhook PeekMessage,PEEKMESSAGE,6,bool
        winhook Pie,PIE,9,bool
        winhook PlayMetaFile,PLAYMETAFILE,2,bool
        winhook PlayMetaFileRecord,PLAYMETAFILERECORD,6,void
        winhook Polygon,POLYGON,4,bool
        winhook Polyline,POLYLINE,4,bool
        winhook PolyPolygon,POLYPOLYGON,6,bool
        winhook PostAppMessage,POSTAPPMESSAGE,5,bool
        winhook PostMessage,POSTMESSAGE,5,bool
        winhook PostQuitMessage,POSTQUITMESSAGE,1,void
        winhook PrestoChangoSelector,PRESTOCHANGOSELECTOR,2,single ; 3.1
        winhook PrintDlg,PRINTDLG,2,bool                        ; 3.1
;       winhook ProfClear
;       winhook ProfFinish
;       winhook ProfFlush
;       winhook ProfInsChk
;       winhook ProfSampRate
;       winhook ProfSetup
;       winhook ProfStart
;       winhook ProfStop
        winhook PtInRect,PTINRECT,3,bool
        winhook PtInRegion,PTINREGION,3,bool
        winhook PtVisible,PTVISIBLE,3,bool
        winhook QueryAbort,QUERYABORT,2,bool                    ; 3.1
        winhook QuerySendMessage,QUERYSENDMESSAGE,5,bool        ; 3.1
        winhook ReadComm,READCOMM,4,single
        winhook RealizePalette,REALIZEPALETTE,1,single
        winhook Rectangle,RECTANGLE,5,bool
        winhook RectInRegion,RECTINREGION,3,bool
        winhook RectVisible,RECTVISIBLE,3,bool
        winhook RedrawWindow,REDRAWWINDOW,5,bool                ; 3.1
        winhook RegisterClass,REGISTERCLASS,2,single
        winhook RegisterClipboardFormat,REGISTERCLIPBOARDFORMAT,2,single
        winhook RegisterWindowMessage,REGISTERWINDOWMESSAGE,2,single
        winhook ReleaseCapture,RELEASECAPTURE,0,void
        winhook ReleaseDC,RELEASEDC,2,single
        winhook RemoveFontResource,REMOVEFONTRESOURCE,2,bool
        winhook RemoveMenu,REMOVEMENU,3,bool
        winhook RemoveProp,REMOVEPROP,3,single
        winhook ReplaceText,REPLACETEXT,2,single                ; 3.1
        winhook ReplyMessage,REPLYMESSAGE,2,void
        winhook ResetDC,RESETDC,3,single                        ; 3.1
        winhook ResizePalette,RESIZEPALETTE,2,bool
        winhook RestoreDC,RESTOREDC,2,bool
        winhook RoundRect,ROUNDRECT,7,bool
        winhook SaveDC,SAVEDC,1,single
        winhook ScaleViewportExt,SCALEVIEWPORTEXT,5,double
        winhook ScaleViewportExtEx,SCALEVIEWPORTEXTEX,7,bool    ; 3.1
        winhook ScaleWindowExt,SCALEWINDOWEXT,5,double
        winhook ScaleWindowExtEx,SCALEWINDOWEXTEX,7,bool        ; 3.1
        winhook ScreenToClient,SCREENTOCLIENT,3,void
        winhook ScrollDC,SCROLLDC,10,bool
        winhook ScrollWindow,SCROLLWINDOW,7,void
        winhook ScrollWindowEx,SCROLLWINDOWEX,11,single         ; 3.1
        winhook SelectClipRgn,SELECTCLIPRGN,2,single
        winhook SelectObject,SELECTOBJECT,2,single
        winhook SelectPalette,SELECTPALETTE,3,single
        winhook SendDlgItemMessage,SENDDLGITEMMESSAGE,6,double
;       winhook SendDriverMessage                               ; 3.1
        winhook SendMessage,SENDMESSAGE,5,double      
        winhook SetAbortProc,SETABORTPROC,3,single              ; 3.1
        winhook SetActiveWindow,SETACTIVEWINDOW,1,single
        winhook SetBitmapBits,SETBITMAPBITS,5,double
        winhook SetBitmapDimension,SETBITMAPDIMENSION,3,double
        winhook SetBitmapDimensionEx,SETBITMAPDIMENSIONEX,5,bool ; 3.1
        winhook SetBkColor,SETBKCOLOR,2,double
        winhook SetBkMode,SETBKMODE,2,single
        winhook SetBoundsRect,SETBOUNDSRECT,4,single            ; 3.1
        winhook SetBrushOrg,SETBRUSHORG,3,double
        winhook SetCapture,SETCAPTURE,1,single
        winhook SetCaretBlinkTime,SETCARETBLINKTIME,1,void
        winhook SetCaretPos,SETCARETPOS,2,void
        winhook SetClassLong,SETCLASSLONG,4,double
        winhook SetClassWord,SETCLASSWORD,3,single
        winhook SetClipboardData,SETCLIPBOARDDATA,2,single
        winhook SetClipboardViewer,SETCLIPBOARDVIEWER,1,single
        winhook SetCommBreak,SETCOMMBREAK,1,single
        winhook SetCommEventMask,SETCOMMEVENTMASK,2,farptr
        winhook SetCommState,SETCOMMSTATE,2,single
        winhook SetCursor,SETCURSOR,1,single
        winhook SetCursorPos,SETCURSORPOS,2,void
        winhook SetDIBits,SETDIBITS,9,single
        winhook SetDIBitsToDevice,SETDIBITSTODEVICE,14,single
        winhook SetDlgItemInt,SETDLGITEMINT,4,void
        winhook SetDlgItemText,SETDLGITEMTEXT,4,void
        winhook SetDoubleClickTime,SETDOUBLECLICKTIME,1,void
        winhook SetEnvironment,SETENVIRONMENT,5,single
        winhook SetErrorMode,SETERRORMODE,1,single
        winhook SetFocus,SETFOCUS,1,single
        winhook SetHandleCount,SETHANDLECOUNT,1,single
        winhook SetKeyboardState,SETKEYBOARDSTATE,2,void
        winhook SetMapMode,SETMAPMODE,2,single
        winhook SetMapperFlags,SETMAPPERFLAGS,3,double
        winhook SetMenu,SETMENU,2,bool
        winhook SetMenuItemBitmaps,SETMENUITEMBITMAPS,5,bool
        winhook SetMessageQueue,SETMESSAGEQUEUE,1,bool
        winhook SetMetaFileBits,SETMETAFILEBITS,1,single
        winhook SetMetaFileBitsBetter,SETMETAFILEBITSBETTER,1,single ; 3.1
        winhook SetPaletteEntries,SETPALETTEENTRIES,5,single
        winhook SetParent,SETPARENT,2,single
        winhook SetPixel,SETPIXEL,5,double
        winhook SetPolyFillMode,SETPOLYFILLMODE,2,single
        winhook SetProp,SETPROP,4,bool
        winhook SetRect,SETRECT,6,void
        winhook SetRectEmpty,SETRECTEMPTY,2,void
        winhook SetRectRgn,SETRECTRGN,5,void
        winhook SetResourceHandler,SETRESOURCEHANDLER,5,farptr
        winhook SetROP2,SETROP2,2,single
        winhook SetScrollPos,SETSCROLLPOS,4,single
        winhook SetScrollRange,SETSCROLLRANGE,5,void
        winhook SetSelectorBase,SETSELECTORBASE,3,single        ; 3.1
        winhook SetSelectorLimit,SETSELECTORLIMIT,3,single      ; 3.1
        winhook SetSoundNoise,SETSOUNDNOISE,2,single
        winhook SetStretchBltMode,SETSTRETCHBLTMODE,2,single
        winhook SetSwapAreaSize,SETSWAPAREASIZE,1,double
        winhook SetSysColors,SETSYSCOLORS,5,void
        winhook SetSysModalWindow,SETSYSMODALWINDOW,1,single
        winhook SetSystemPaletteUse,SETSYSTEMPALETTEUSE,2,single
        winhook SetTextAlign,SETTEXTALIGN,2,single
        winhook SetTextCharacterExtra,SETTEXTCHARACTEREXTRA,2,single
        winhook SetTextColor,SETTEXTCOLOR,3,double
        winhook SetTextJustification,SETTEXTJUSTIFICATION,3,single
        winhook SetTimer,SETTIMER,5,single
        winhook SetViewportExt,SETVIEWPORTEXT,3,double
        winhook SetViewportExtEx,SETVIEWPORTEXTEX,5,bool        ; 3.1
        winhook SetViewportOrg,SETVIEWPORTORG,3,double
        winhook SetViewportOrgEx,SETVIEWPORTORGEX,5,bool        ; 3.1
;       winhook SetVoiceAccent,SETVOICEACCENT,5,single          ; obs 3.1
;       winhook SetVoiceEnvelope,SETVOICEENVELOPE,3,single      ; obs 3.1
;       winhook SetVoiceNote,SETVOICENOTE,4,single              ; obs 3.1
;       winhook SetVoiceQueueSize,SETVOICEQUEUESIZE,2,single    ; obs 3.1
;       winhook SetVoiceSound,SETVOICESOUND,4,single            ; obs 3.1
;       winhook SetVoiceThreshold,SETVOICETHRESHOLD,2,single    ; obs 3.1
        winhook SetWindowExt,SETWINDOWEXT,3,double
        winhook SetWindowExtEx,SETWINDOWEXTEX,5,bool            ; 3.1
        winhook SetWindowLong,SETWINDOWLONG,4,double
        winhook SetWindowOrg,SETWINDOWORG,3,double
        winhook SetWindowOrgEx,SETWINDOWORGEX,5,bool            ; 3.1
        winhook SetWindowPlacement,SETWINDOWPLACEMENT,3,bool    ; 3.1
        winhook SetWindowPos,SETWINDOWPOS,7,bool                ; chgd in 3.1
        winhook SetWindowsHook,SETWINDOWSHOOK,3,farptr
        winhook SetWindowsHookEx,SETWINDOWSHOOKEX,5,single      ; 3.1
        winhook SetWindowText,SETWINDOWTEXT,3,void
        winhook SetWindowWord,SETWINDOWWORD,3,single
        winhook ShowCaret,SHOWCARET,1,void
        winhook ShowCursor,SHOWCURSOR,1,single
        winhook ShowOwnedPopups,SHOWOWNEDPOPUPS,2,void
        winhook ShowScrollBar,SHOWSCROLLBAR,3,void
        winhook ShowWindow,SHOWWINDOW,2,bool
        winhook SizeofResource,SIZEOFRESOURCE,2,single
        winhook StartDoc,STARTDOC,3,single                      ; 3.1
        winhook StartPage,STARTPAGE,1,single                    ; 3.1
;       winhook StartSound,STARTSOUND,0,single                  ; obs 3.1
;       winhook StopSound,STOPSOUND,0,single                    ; obs 3.1
        winhook StretchBlt,STRETCHBLT,12,bool
        winhook StretchDIBits,STRETCHDIBITS,16,single
        winhook SubtractRect,SUBTRACTRECT,6,bool                ; 3.1
        winhook SwapMouseButton,SWAPMOUSEBUTTON,1,bool
;       winhook SwapRecording,SWAPRECORDING,1,void              ; obs 3.1
        winhook SwitchStackBack,SWITCHSTACKBACK,0,void
        winhook SwitchStackTo,SWITCHSTACKTO,3,void
;       winhook SyncAllVoices,SYNCALLVOICES,0,single            ; obs 3.1
        winhook SystemHeapInfo,SYSTEMHEAPINFO,2,bool            ; 3.1
        winhook SystemParametersInfo,SYSTEMPARAMETERSINFO,5,bool ; 3.1
        winhook TabbedTextOut,TABBEDTEXTOUT,10,double
        winhook TaskFindHandle,TASKFINDHANDLE,3,bool            ; 3.1
        winhook TaskFirst,TASKFIRST,2,bool                      ; 3.1
        winhook TaskGetCSIP,TASKGETCSIP,1,double                ; 3.1
        winhook TaskNext,TASKNEXT,2,bool                        ; 3.1
        winhook TaskSetCSIP,TASKSETCSIP,3,double                ; 3.1
        winhook TaskSwitch,TASKSWITCH,3,bool                    ; 3.1
        winhook TerminateApp,TERMINATEAPP,2,void                ; 3.1
        winhook TextOut,TEXTOUT,6,bool
        winhook Throw,THROW,3,void
        winhook TimerCount,TIMERCOUNT,2,bool                    ; 3.1
        winhook ToAscii,TOASCII,7,single
        winhook TrackPopupMenu,TRACKPOPUPMENU,8,bool
        winhook TranslateAccelerator,TRANSLATEACCELERATOR,4,single
        winhook TranslateMDISysAccel,TRANSLATEMDISYSACCEL,3,bool
        winhook TranslateMessage,TRANSLATEMESSAGE,2,bool
        winhook TransmitCommChar,TRANSMITCOMMCHAR,2,single
        winhook UngetCommChar,UNGETCOMMCHAR,2,single
        winhook UnhookWindowsHook,UNHOOKWINDOWSHOOK,3,bool
        winhook UnhookWindowsHookEx,UNHOOKWINDOWSHOOKEX,1,bool  ; 3.1
        winhook UnionRect,UNIONRECT,6,single
        winhook UnlockSegment,UNLOCKSEGMENT,1,bool
        winhook UnrealizeObject,UNREALIZEOBJECT,1,bool
        winhook UnregisterClass,UNREGISTERCLASS,3,bool
        winhook UpdateColors,UPDATECOLORS,1,single
        winhook UpdateWindow,UPDATEWINDOW,1,void
        winhook ValidateRect,VALIDATERECT,3,void
        winhook ValidateRgn,VALIDATERGN,2,void
        winhook VerFindFile,VERFINDFILE,15,single               ; 3.1
        winhook VerInstallFile,VERINSTALLFILE,15,double         ; 3.1
        winhook VerLanguageName,VERLANGUAGENAME,4,single        ; 3.1
        winhook VerQueryValue,VERQUERYVALUE,8,bool              ; 3.1
        winhook VkKeyScan,VKKEYSCAN,1,single
        winhook WaitMessage,WAITMESSAGE,0,void
;       winhook WaitSoundState,WAITSOUNDSTATE,1,single          ; obs 3.1
        winhook WindowFromPoint,WINDOWFROMPOINT,2,single
        winhook WinExec,WINEXEC,3,single
        winhook WinHelp,WINHELP,6,bool
        winhook WriteComm,WRITECOMM,4,single
        winhook WritePrivateProfileString,WRITEPRIVATEPROFILESTRING,8,bool
        winhook WriteProfileString,WRITEPROFILESTRING,6,bool
        winhook Yield,YIELD,0,void

        end

