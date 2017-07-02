#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.0.1	
#include <FilterDialog> menus=0
#pragma IgorVersion = 6.1	//Igor Pro 6.1 or later

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This procedure (miniAna) offers an analytical environment for miniature events.
// Latest version is available at Github (https://github.com/yuichi-takeuchi/miniAna).
//
// Prerequisites:
//* Igor Pro 6.1 or later
//* tUtility (https://github.com/yuichi-takeuchi/tUtility)
//* SetWindowExt.XOP (http://fermi.uchicago.edu/freeware/LoomisWood/SetWindowExt.shtml)
//
// Author:
// Yuichi Takeuchi PhD
// Department of Physiology, University of Szeged, Hungary
// Email: yuichi-takeuchi@umin.net
// 
// Lisence:
// MIT License
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Menu "miniAna"
	"MiniAnaMain", t_MiniAna()
	"Hide", t_HideWindowMiniAnaMain()
	"DisplayMiniAna_Main", t_DoWindowMiniAnaMain()
	"CloseMiniAna", t_CloseMiniAnaWindows()
	SubMenu "miniAna.ipf"
		"Display Procedure", DisplayProcedure/W= 'miniAna.ipf'
		"Main", DisplayProcedure/W= 'miniAna.ipf' "t_MiniAnaMain"
		"Table", DisplayProcedure/W= 'miniAna.ipf' "t_MiniAnaTable"
		"ParentGraph", DisplayProcedure/W= 'miniAna.ipf' "t_MiniAnaParentGraph"
		"DaughterGraph", DisplayProcedure/W= 'miniAna.ipf' "t_MiniAnaDaughterGraph"
		"EvengGraph", DisplayProcedure/W= 'miniAna.ipf' "t_MiniAnaEventGraph"
		"Help", DisplayProcedure/W= 'miniAna.ipf' "t_MiniAnaHelpNote"
	End
	"Help", t_MiniAnaHelpNote("")
End

Menu "GraphMarquee"
	"IsoAddAll_Mini", t_IsoAddAll_Mini()
	"CoAddAll_Mini", t_CoAddAll_Mini()
	"IsoModAll_Mini", t_IsoModAll_Mini()
	"CoModAll_Mini", t_CoModAll_Mini()
	"Delete_Mini", t_Delete_Mini()
End

Function t_MiniHook(StringSwitch)
	String StringSwitch
	StrSwitch (StringSwitch)
		case "Isolate add":
			t_IsoAddAll_Mini()
			break
		case "Complex add":
			t_CoAddAll_Mini()
			break
		case "Isolate mod":
			t_IsoModAll_Mini()
			break
		case "Complex mod":
			t_CoModAll_Mini()
			break
		case "Delete":
			t_Delete_Mini()
			break
		default:
			break
	endSwitch
end

//////////////////////////////////////////////////////////////////////
//Menu
Function t_MiniAna()
	t_MiniAnaPrepWave()
	t_MiniAnaPrepGV()
	t_MiniAnaMain()
	t_MiniAnaTable()
	t_MiniAnaParentGraph()
	t_MiniAnaDaughterGraph()
	t_MiniAnaEventGraph()
end

Function t_HideWindowMiniAnaMain()
	DoWindow/Hide = 1 MiniAnaMain
	DoWindow/Hide = 1 MiniAnaTable
	DoWindow/Hide = 1 MinianaParentGraph
	DoWindow/Hide = 1 MiniAnaDaughterGraph
	DoWindow/Hide = 1 MiniAnaEventGraph
end

Function t_DoWindowMiniAnaMain()
	DoWindow/F MiniAnaMain
	DoWindow/F MiniAnaTable
	DoWindow/F MinianaParentGraph
	DoWindow/F MiniAnaDaughterGraph
	DoWindow/F MiniAnaEventGraph
end

Function t_CloseMiniAnaWindows()
	DoWindow/K MiniAnaMain
	DoWindow/K MiniAnaTable
	DoWindow/K MinianaParentGraph
	DoWindow/K MiniAnaDaughterGraph
	DoWindow/K MiniAnaEventGraph
end

Function t_MiniFolderCheck()
	If(DataFolderExists("root:Packages:MiniAna"))
		else
			If(DataFolderExists("root:Packages"))
					NewDataFolder root:Packages:MiniAna
				else
					NewDataFolder root:Packages
					NewDataFolder root:Packages:MiniAna
			endif
	endif
End

Function t_MiniAnaPrepWave()
	t_MiniFolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna
	
	If(Exists("Mini_SampleWave")==1)
	
	else
		Make/n=1000 Mini_SampleWave
	endif
	
	Wave Mini_SampleWave
	Mini_SampleWave = 2*exp(-(x/1)) -2*exp(- (x/5)) + gnoise(0.1)
	Duplicate/O Mini_SampleWave MA_LabelingWave0
	MA_labelingWave0 = 0
	Duplicate/O Mini_SampleWave MA_LabelingWave1
	Ma_LabelingWave1 = 0
	
	If(Exists("Mini_WaveListWave") == 1)
	
	else
		Make/n=1/T Mini_WaveListWave
	endIf

	If(Exists("MiniLb2D") == 1)
	
	else
		Make/n=(1, 16)/T MiniLb2D
	endIf
	MiniLb2D = ""
	SetDataFolder fldrSav0
end

Function t_MiniAnaPrepGV()
	t_MiniFolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna
	
	Variable/G MiniK = 4
	Variable/G SetMiniPCurrent = 0
	Variable/G SetMiniTotalRange = 0.02
	Variable/G SetMiniBasalRange = 0.001
	Variable/G SetMiniTimeInitial = 0
	Variable/G SetMiniTimeFinish = 0.8
	Variable/G MiniAnaScaleMax = 20e-12
	Variable/G MiniAnaScaleMin = -120e-12
	Variable/G SetMiniArtifactX = 0.05
	Variable/G SetMiniFitTimeInitial = 0.055
	Variable/G SetMiniFitTimeFinish = 1
	Variable/G DetectPeakAmp = 10e-12
	Variable/G DetectPeakSD = 3
	Variable/G DetectArea = -1e-15
	Variable/G DetectAreaDecayRange = 0.003
	Variable/G DetectIsoCriteria = 0.01
	Variable/G DetectSmoothingBox = 100
	Variable/G Detecttightness = 10
	Variable/G DetecttightBack = 10
	Variable/G EventSerial = 1
	Variable/G EventXLock = 0
	Variable/G gvError = 0
	Variable/G MiniDispPeak = 0
	Variable/G MiniDispArea = 0
	Variable/G MiniDispRise = 0
	Variable/G MiniDispDecay = 0
	String/G ExpRecNum = "1"
	String/G SamplingHz = "50"
	String/G tWaveMini = "WaveName"
	String/G DisplayingWaveMini = "Demo"
	String/G MiniAnaEventNum = "EventNum"
	String/G EventWaveName
	
	SetDataFolder fldrSav0
end

Function t_MiniAnaHelpNote(ctrlName) : ButtonControl
	String ctrlName

	NewNotebook/F=0/N=MiniAnaHelpNote
	String strhelp =""
	strhelp += "0. Click MiniAnaMain (Menu -> MiniAna -> MiniAnaMain)"+"\r"
	strhelp += "1. Set ExpRecNum, Sampling (kHz), ParrentCurrents, and other parameters at \"Set\" tab on the MiniAnaMain Window."+"\r"
	strhelp += "2. Get Wavelist into the listbox and specify the target wave from the wavelist (tWaveMini)"+"\r"
	strhelp += "3. Click TablePrep"+"\r"
	strhelp += "4. Click Display"+"\r"
	strhelp += "5. AutoSearch (If Shift is pressed, preparation only)"+"\r"
	strhelp += "6. Shift + Scale button (DaughterGraph)" + "\r"
	strhelp += "7. Modify Events (DaughterGraph)"+"\r"
	strhelp += "8. Next Sw (DaughterGraph)"+"\r"
	strhelp += "9. Repeat 5 - 7, or AllSearch instead of AutoSearch"+"\r"
	strhelp += "10. EditT0 (Table)"+"\r"
	strhelp += "11. Output (Save) Table0 as .csv etc."+"\r"
	strhelp += "12. EventSum, EventSumIX, or EventSumAv creats AveragedEvent from isolated events"+"\r"
	strhelp += ""+"\r"
	strhelp += "ShortCutKey (dauther graph); default hooked. To release the hook, Shift + HookOnOFF"+"\r"
	strhelp += "During marquee"+"\r"
	strhelp += "\"A\": IsoAdAll"+"\r"
	strhelp += "\"Shift + A\": CoAdAll"+"\r"
	strhelp += "\"M\": IsoMdAll\""+"\r"
	strhelp += "\"Shift + M\": CoMdAll"+"\r"
	strhelp += "Others"+"\r"
	strhelp += "\"D\": Delete"+"\r"
	strhelp += "\"N\":  Next (events)"+"\r"
	strhelp += "\"C\": LabelW = NaN "+"\r"
	strhelp += "\"E\": EraceCursors"+"\r"
	strhelp += ""+"\r"
	Notebook MiniAnaHelpNote selection={endOfFile, endOfFile}
	Notebook MiniAnaHelpNote text = strhelp + "\r"	
end

///////////////////////////////////////////////////////////////////
//Main
Function t_MiniAnaMain()
	PauseUpdate; Silent 1		// building window...
	NewPanel/N=MiniAnaMain/W=(653,56,1170,337)
	ShowTools/A
	TabControl tb6,pos={2,1},size={514,280},proc=t_TabProc05,tabLabel(0)="Main"
	TabControl tb6,tabLabel(1)="Set",tabLabel(2)="Detect",tabLabel(3)="Field0"
	TabControl tb6,tabLabel(4)="Help",value= 0

//tab0
	Button BtSelecttWaveMini_tab0,pos={12,25},size={70,20},proc=t_SelecttWaveMini,title="tWaveMini"
	SetVariable SetVartWavemini_tab0,pos={88,28},size={100,16},title=" "
	SetVariable SetVartWavemini_tab0,value= root:Packages:MiniAna:tWaveMini
	PopupMenu PoptWave_tab0,pos={15,50},size={111,20},bodyWidth=75,proc=t_MinitWaveSelection60,title="select"
	PopupMenu PoptWave_tab0,mode=1,popvalue="w_1_0_0",value= #"wavelist(\"*\", \";\", \"\")"
	PopupMenu PoptWaveAddition_tab0,pos={19,75},size={98,20},bodyWidth=75,proc=t_MinitWaveAddition60,title="add"
	PopupMenu PoptWaveAddition_tab0,mode=1,popvalue="w_1_0_0",value= #"wavelist(\"*\", \";\", \"\")"
	ListBox MiniWaveList_tab0,pos={343,61},size={152,207},frame=2
	ListBox MiniWaveList_tab0,listWave=root:Packages:MiniAna:Mini_WaveListWave,mode= 1
	ListBox MiniWaveList_tab0,selRow= -1
	Button EditMini_tab0,pos={342,36},size={50,20},proc=t_MiniEditList,title="EditList"
	Button BtMiniDeleteListWave_tab0,pos={395,36},size={50,20},proc=t_MiniDeleteWaveList,title="Delete"
	Button BtMiniMainGetWL_tab0,pos={446,36},size={50,20},proc=t_MiniGetWaveList,title="GetWL"
	Button BtMniTablePreparation_tab0,pos={15,110},size={70,20},proc=t_MiniTablePrep,title="TablePrep"
	Button BtMniWavePreparation_tab0,pos={85,110},size={70,20},proc=t_MiniAnaWavePrep,title="WavePrep"
	Button BtDisplayInittWaveMini_tab0,pos={15,130},size={70,20},proc=t_MiniMainDisplayInitialize,title="DisplayInit"
	Button BtAutoSearch_tab0,pos={15,150},size={70,20},proc=t_MiniAutoSearch,title="AutoSearch"
	Button Bt_Abort_tab0,pos={85,150},size={70,20},proc=t_MiniAllSearch,title="AllSearch"
	Button BtReset_tab0,pos={15,190},size={50,20},title="Reset"
	Button Bt_MiniD_Rec_tab0,pos={15,240},size={50,20},proc=t_RecoveryMiniAnaDaughterGraph,title="D_Recov"
	Button BtDisplaytWaveMini_tab0,pos={85,130},size={70,20},proc=t_MiniMainDisplay,title="Display"	
	TitleBox TitleBoxRecNumber_tab0,pos={235,25},size={83,20}
	TitleBox TitleBoxRecNumber_tab0,variable= root:Packages:MiniAna:ExpRecNum
	TitleBox TitleMiniSamplingHz_tab0,pos={236,46},size={67,20}
	TitleBox TitleMiniSamplingHz_tab0,variable= root:Packages:MiniAna:SamplingHz

//tab1
	SetVariable MiniSetExpRecNum_tab1,pos={10,27},size={150,16}
	SetVariable MiniSetExpRecNum_tab1,value= root:Packages:MiniAna:ExpRecNum
	SetVariable MiniSetSampling_tab1,pos={10,46},size={150,16},title="Sampling (kHz)"
	SetVariable MiniSetSampling_tab1,value= root:Packages:MiniAna:SamplingHz	
	SetVariable MiniSetPCurrent_tab1,pos={10,66},size={150,16},title="ParentCurrent"
	SetVariable MiniSetPCurrent_tab1,limits={0,inf,1e-12},value= root:Packages:MiniAna:SetMiniPCurrent
	GroupBox GroupMiniMain_tab1,pos={8,104},size={169,73},title="Event Range (s)"
	SetVariable SetMiniTotalRange_tab1,pos={21,124},size={150,16},title="Total"
	SetVariable SetMiniTotalRange_tab1,limits={0.001,inf,0.001},value= root:Packages:MiniAna:SetMiniTotalRange
	SetVariable SetMiniBasalRange_tab1,pos={21,146},size={150,16},title="Base"
	SetVariable SetMiniBasalRange_tab1,limits={0.001,inf,0.001},value= root:Packages:MiniAna:SetMiniBasalRange
	CheckBox CheckSetDupLW_tab1,pos={19,186},size={97,14},proc=t_MiniCheck_tab1,title="Labeling Waves"
	CheckBox CheckSetDupLW_tab1,value= 1
	CheckBox CheckSetDupEW_tab1,pos={19,215},size={84,14},proc=t_MiniCheck_tab1,title="Event Waves"
	CheckBox CheckSetDupEW_tab1,value= 0
	CheckBox CheckSetDisplayEW_tab1,pos={20,242},size={76,14},title="Diplay EWs"
	CheckBox CheckSetDisplayEW_tab1,value= 0
	PopupMenu Popup_AnalysisMode_tab1,pos={196,25},size={152,24},proc=t_PopMenuProcMiniSet,title="Mode"
	PopupMenu Popup_AnalysisMode_tab1,mode=2,popvalue="Mini or Sponta",value= #"\"Evoked Mini;Mini or Sponta\""
	GroupBox GroupTimeWindow_tab1,pos={202,49},size={129,62},title="TimeWindow (s)"
	SetVariable SetInitialTime_tab1,pos={219,67},size={100,16},title="From"
	SetVariable SetInitialTime_tab1,limits={0,inf,0.001},value= root:Packages:MiniAna:SetMiniTimeInitial
	SetVariable SetFinishTime_tab1,pos={219,86},size={100,16},title="To"
	SetVariable SetFinishTime_tab1,limits={0,inf,0.001},value= root:Packages:MiniAna:SetMiniTimeFinish
	GroupBox GroupScale_tab1,pos={202,119},size={129,62},title="Axis Scaling"
	SetVariable SetMiniAnaScalingMax_tab1,pos={219,137},size={100,16},title="Max"
	SetVariable SetMiniAnaScalingMax_tab1,limits={0,inf,1e-12},value= root:Packages:MiniAna:MiniAnaScaleMax
	SetVariable SetMiniAnaScalingMin_tab1,pos={219,156},size={100,16},title="Min"
	SetVariable SetMiniAnaScalingMin_tab1,limits={-inf,inf,0.001},value= root:Packages:MiniAna:MiniAnaScaleMin
	SetVariable SetArtifact_tab1,pos={347,28},size={70,16},title="ArtiX"
	SetVariable SetArtifact_tab1,value= root:Packages:MiniAna:SetMiniArtifactX
	PopupMenu Popup_Fitting_tab1,pos={347,48},size={97,24},title="BaseFit"
	PopupMenu Popup_Fitting_tab1,mode=2,popvalue="line",value= #"\"none;line;poly;lor;exp_XOffset;dblexp_XOffset;exp;dbexp;\""
	GroupBox Groupfit_tab1,pos={338,74},size={113,73},title="Fittig Range"
	SetVariable SetInitialTime_tab1,pos={219,67},size={100,16},disable=2,title="From"
	SetVariable SetInitialTime_tab1,limits={0,inf,0.001},value= root:Packages:MiniAna:SetMiniTimeInitial
	SetVariable SetFinishTime_tab1,pos={219,86},size={100,16},disable=2,title="To"
	SetVariable SetFinishTime_tab1,limits={0,inf,0.001},value= root:Packages:MiniAna:SetMiniTimeFinish
	CheckBox CheckFitEvent_tab1,pos={206,187},size={84,14},title="Event Fitting"
	CheckBox CheckFitEvent_tab1,value= 0

//tab2
	GroupBox GroupPeak_tab2,pos={15,25},size={237,142},title="Peak Detection"
	PopupMenu PopupPeakDetect_tab2,pos={31,41},size={87,20},title="Polarity"
	PopupMenu PopupPeakDetect_tab2,mode=1,popvalue="-",value= #"\"-;+;Å};\""
	SetVariable SetPeakAmplitude_tab2,pos={32,64},size={150,16},title="Amp (A or V)"
	SetVariable SetPeakAmplitude_tab2,limits={0,inf,1e-12},value= root:Packages:MiniAna:DetectPeakAmp
	SetVariable SetPeakfromSD_tab2,pos={33,87},size={75,16},title="Å~S.D."
	SetVariable SetPeakfromSD_tab2,limits={0,inf,1},value= root:Packages:MiniAna:DetectPeakSD
	SetVariable SetPeakBox_tab2,pos={28,119},size={100,16},title="Smoothing"
	SetVariable SetPeakBox_tab2,limits={0,inf,1},value= root:Packages:MiniAna:DetectSmoothingBox
	SetVariable SetTightnessBack_tab2,pos={26,141},size={90,16},title="TightBack"
	SetVariable SetTightnessBack_tab2,limits={0,inf,1},value= root:Packages:MiniAna:DetecttightBack
	SetVariable SetTightness_tab2,pos={132,141},size={90,16},title="Tightness"
	SetVariable SetTightness_tab2,limits={0,inf,1},value= root:Packages:MiniAna:Detecttightness
	CheckBox CheckMADetectArea_tab2,pos={27,174},size={16,14},title="",value= 1
	SetVariable SetArea_tab2,pos={47,172},size={123,16},title="Area"
	SetVariable SetArea_tab2,limits={0,inf,1e-15},value= root:Packages:MiniAna:DetectArea
	SetVariable SetAreaRange_tab2,pos={174,173},size={80,16},title="Range"
	SetVariable SetAreaRange_tab2,limits={0,inf,0.001},value= root:Packages:MiniAna:DetectAreaDecayRange
	GroupBox GroupFitting_tab2,pos={15,194},size={237,75},title="Fitting Parameters"
	GroupBox GroupIsolate_tab2,pos={287,29},size={208,64},title="Isolating Criteria"
	SetVariable SetDetect_IsoCri_tab2,pos={300,50},size={150,16}
	SetVariable SetDetect_IsoCri_tab2,limits={0,inf,0.01},value= root:Packages:MiniAna:DetectIsoCriteria

//tab3
	GroupBox GroupField0_tab3,pos={11,23},size={198,113},title="default"
	CheckBox CheckExpRecNum_tab3,pos={20,40},size={80,14},proc=t_MAFieldCheck,title="ExpRecNum"
	CheckBox CheckExpRecNum_tab3,value= 1
	CheckBox CheckWaveName_tab3,pos={19,58},size={74,14},proc=t_MAFieldCheck,title="WaveName"
	CheckBox CheckWaveName_tab3,value= 1
	CheckBox CheckSamplingHz_tab3,pos={19,76},size={77,14},proc=t_MAFieldCheck,title="SamplingHz"
	CheckBox CheckSamplingHz_tab3,value= 1
	CheckBox CheckParentCurrent_tab3,pos={19,90},size={63,14},proc=t_MAFieldCheck,title="PCurrent",value= 1
	CheckBox CheckIsolateTag_tab3,pos={20,108},size={71,14},proc=t_MAFieldCheck,title="IsolateTag",value= 1
	CheckBox CheckSerial_tab3,pos={120,44},size={70,14},proc=t_MAFieldCheck,title="SerialNum", value = 1
	CheckBox CheckXLock_tab3,pos={121,65},size={69,14},proc=t_MAFieldCheck,title="XLock", value = 1
	CheckBox CheckALockedX_tab3,pos={122,85},size={69,14},proc=t_MAFieldCheck,title="ALockedX", value = 1
	CheckBox CheckInitialX_tab3,pos={123,103},size={53,14},proc=t_MAFieldCheck,title="InitialX",value= 1
	CheckBox CheckInterEventInterval_tab3,pos={123,119},size={66,14},proc=t_MAFieldCheck,title="IEInterval",value= 1
	CheckBox CheckBase_tab3,pos={124,143},size={44,14},proc=t_MAFieldCheck,title="Base", value = 1
	CheckBox CheckError_tab3,pos={125,162},size={43,14},proc=t_MAFieldCheck,title="Error",value= 1
	CheckBox CheckPeak_tab3,pos={19,144},size={43,14},proc=t_MAFieldCheck,title="Peak", value = 1
	CheckBox CheckArea_tab3,pos={20,161},size={42,14},proc=t_MAFieldCheck,title="Area", value = 1
	CheckBox CheckDecay_tab3,pos={20,176},size={50,14},proc=t_MAFieldCheck,title="Decay", value = 1
	CheckBox CheckDRise_tab3,pos={20,193},size={41,14},proc=t_MAFieldCheck,title="Rise", value = 1

//tab4
	Button BtHelp_tab4,pos={20,30},size={50,20},proc= t_MiniAnaHelpNote,title="Help"

//
	ModifyControlList ControlNameList("",";","!*_tab0") disable=1
	ModifyControl tb6 disable=0
	DefineGuide UGV0={FR,-352}
end

Function t_TabProc05 (ctrlName, tabNum) : TabControl
	String ctrlname
	Variable tabNum
	String controlsInATab= ControlNameList("",";","*_tab*")
	String curTabMatch="*_tab"+Num2str(tabNum)
	String controlsInCurTab= ListMatch(controlsInATab, curTabMatch)
	String controlsInOtherTab= ListMatch(controlsInATab, "!"+curTabMatch)
	ModifyControlList controlsInCurTab disable = 0 //show
	ModifyControlList controlsInOtherTab disable = 1 //hide
end

Function t_SelecttWaveMini(ctrlName) : ButtonControl
	String ctrlName
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	Wave/T ListWave = root:Packages:MiniAna:Mini_WaveListWave
	ControlInfo/W=MiniAnaMain MiniWaveList_tab0
	tWaveMini = ListWave[V_Value]
End

Function t_MinitWaveSelection60(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	tWaveMini = popStr
	Wave/T ListWave = root:Packages:MiniAna:Mini_WaveListWave
	Redimension/N=1 ListWave
	ListWave[0] = {popStr}
End

Function t_MinitWaveAddition60(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	tWaveMini = popStr
	Wave/T ListWave = root:Packages:MiniAna:Mini_WaveListWave
	Redimension/N=(numpnts(ListWave)+1) ListWave
	ListWave[numpnts(ListWave)-1] = {popStr}
End

Function t_MiniEditList(ctrlName) : ButtonControl
	String ctrlName
	Wave ListWave = root:Packages:MiniAna:Mini_WaveListWave
	Edit ListWave
End

Function t_MiniDeleteWaveList(ctrlName) : ButtonControl
	String ctrlName
	Wave ListWave = root:Packages:MiniAna:Mini_WaveListWave
	ControlInfo/W=MiniAnaMain MiniWaveList_tab0
	DeletePoints V_Value, 1, ListWave
End

Function t_MiniGetWaveList(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR tWL = root:Packages:YT:tWL
	Wave/T tMiniWL = root:Packages:MiniAna:Mini_WaveListWave
	String SFL
	Variable i = 0
	Redimension/N=0 tMiniWL
	do
		SFL = StringFromList(i, tWL, ";")
		If(Strlen(SFL)<1)
			break
		endIf
		Insertpoints (numpnts(tMiniWL)+1), 1, tMiniWL
		tMiniWL[numpnts(tMiniWL)] = SFL
		i += 1
	while(1)
End

Function t_MiniMainDisplayInitialize(ctrlName) : ButtonControl
	String ctrlName
	SVAR DisplayingWaveMini = root:Packages:MiniAna:DisplayingWaveMini
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR MiniDispPeak =  root:Packages:MiniAna:MiniDispPeak
	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	EventWaveName = tWaveMini
	DisplayingWaveMini = tWaveMini
	
	ControlInfo/W=MiniAnaMain CheckSetDupLW_tab1
	If(V_value)
		String Label0 = tWaveMini + "_Label0"
		String Label1 = tWaveMini + "_Label1"
		If(Exists(Label0) == 0)
			Duplicate/O $tWaveMini, $Label0
			Wave wLabel0 = $Label0
			wLabel0 = NaN
		else
			Wave wLabel0 = $Label0			
		endif
		If(Exists(Label1) == 0)
			Duplicate/O $tWaveMini, $Label1
			Wave wLabel1 = $Label1
			wLabel1 = NaN		
		else
			Wave wLabel1 = $Label1			
		endif
		RemoveFromGraph/W=MiniAnaDaughterGraph MA_LabelingWave0,MA_LabelingWave1
		RemoveFromGraph/W=MiniAnaParentGraph MA_LabelingWave0,MA_LabelingWave1
		RemoveFromGraph/W=MiniAnaEventGraph MA_LabelingWave0,MA_LabelingWave1
	endIf
	
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna
	DoWindow/F MiniAnaDaughterGraph
	String sdw = StringFromList(0, Wavelist("*", ";", "WIN:"))
	DoWindow/F MiniAnaParentGraph
	String tdw = StringFromList(0, Wavelist("*", ";", "WIN:"))
	DoWindow/F MiniAnaEventGraph
	String udw = StringFromList(0, Wavelist("*", ";", "WIN:"))
	If(Strlen(sdw)>1)
		RemoveFromGraph/W=MiniAnaDaughterGraph $sdw
	endIf
	If(Strlen(tdw)>1)
		RemoveFromGraph/W=MiniAnaParentGraph $tdw
	endIf
	If(Strlen(udw)>1)
		RemoveFromGraph/W=MiniAnaEventGraph $udw
	endIf
	SetDataFolder fldrSav0
	DoWindow/F MiniAnaDaughterGraph
	sdw = StringFromList(0, Wavelist("*", ";", "WIN:"))
	DoWindow/F MiniAnaParentGraph
	tdw = StringFromList(0, Wavelist("*", ";", "WIN:"))
	DoWindow/F MiniAnaEventGraph
	udw = StringFromList(0, Wavelist("*", ";", "WIN:"))
	If(Strlen(sdw)>1)
		RemoveFromGraph/W=MiniAnaDaughterGraph $sdw
	endIf
	If(Strlen(tdw)>1)
		RemoveFromGraph/W=MiniAnaParentGraph $tdw
	endIf
	If(Strlen(udw)>1)
		RemoveFromGraph/W=MiniAnaEventGraph $udw
	endIf

	AppendToGraph/W=MiniAnaDaughterGraph $tWaveMini
	AppendToGraph/W=MiniAnaParentGraph $tWaveMini
	AppendToGraph/W=MiniAnaEventGraph $tWaveMini
//	Cursor/W=MiniAnaEventGraph A $tWaveMini 0
//	Cursor/W=MiniAnaEventGraph B $tWaveMini 0
//	Cursor/W=MiniAnaEventGraph C $tWaveMini 0
//	ControlInfo/W=MiniAnaMain CheckSetDupLW_tab1
	If(V_Value)
		Duplicate/O $tWaveMini root:Packages:MiniAna:MA_LabelingWave0, root:Packages:MiniAna:MA_LabelingWave1
//		fldrSav0= GetDataFolder(1)
//		SetDataFolder root:Packages:MiniAna
		Wave MA_labelingWave0 = root:Packages:MiniAna:MA_LabelingWave0
		Wave MA_LabelingWave1 = root:Packages:MiniAna:MA_LabelingWave1
		MA_LabelingWave0 = NaN
		MA_LabelingWave1 = NaN
//		Wave MA_labelingWave0
//		Wave MA_labelingWave1
		AppendToGraph/W=MiniAnaDaughterGraph/L=MA_LabelAxis0 MA_LabelingWave0
		AppendToGraph/W=MiniAnaDaughterGraph/L=MA_LabelAxis1 MA_LabelingWave1
		AppendToGraph/W=MiniAnaParentGraph/L=MA_LabelAxis0 MA_LabelingWave0
		AppendToGraph/W=MiniAnaParentGraph/L=MA_LabelAxis1 MA_LabelingWave1
		AppendToGraph/W=MiniAnaEventGraph/L=MA_LabelAxis0 MA_LabelingWave0
		AppendToGraph/W=MiniAnaEventGraph/L=MA_LabelAxis1 MA_LabelingWave1
//		SetDataFolder fldrSav0
//		DoUpdate
		ModifyGraph/W=MiniAnaDaughterGraph mode(MA_LabelingWave0)=3,mode(MA_LabelingWave1)=3
		ModifyGraph/W=MiniAnaDaughterGraph marker(MA_LabelingWave0)=10,marker(MA_LabelingWave1)=10
		ModifyGraph/W=MiniAnaDaughterGraph rgb(MA_LabelingWave1)=(0,0,65280)
		ModifyGraph/W=MiniAnaDaughterGraph msize(MA_LabelingWave0)=2,msize(MA_LabelingWave1)=2
		ModifyGraph/W=MiniAnaDaughterGraph noLabel(MA_LabelAxis0)=2,noLabel(MA_LabelAxis1)=2
		ModifyGraph/W=MiniAnaDaughterGraph axThick(MA_LabelAxis0)=0,axThick(MA_LabelAxis1)=0
		ModifyGraph/W=MiniAnaDaughterGraph freePos(MA_LabelAxis0)=0
		ModifyGraph/W=MiniAnaDaughterGraph freePos(MA_LabelAxis1)=0
		ModifyGraph/W=MiniAnaDaughterGraph lblPos(left)=0, lblPos(bottom)=0
		ModifyGraph/W=MiniAnaDaughterGraph lblLatPos(left)=0,lblLatPos(bottom)=0
		ModifyGraph/W=MiniAnaDaughterGraph axisEnab(MA_LabelAxis0)={0.9,0.95}
		ModifyGraph/W=MiniAnaDaughterGraph axisEnab(MA_LabelAxis1)={0.95,1}
		ModifyGraph/W=MiniAnaDaughterGraph axisEnab(left)={0,0.9}
		ModifyGraph/W=MiniAnaParentGraph mode(MA_LabelingWave0)=3,mode(MA_LabelingWave1)=3
		ModifyGraph/W=MiniAnaParentGraph marker(MA_LabelingWave0)=10,marker(MA_LabelingWave1)=10
		ModifyGraph/W=MiniAnaParentGraph rgb(MA_LabelingWave1)=(0,0,65280)
		ModifyGraph/W=MiniAnaParentGraph msize(MA_LabelingWave0)=2,msize(MA_LabelingWave1)=2
		ModifyGraph/W=MiniAnaParentGraph noLabel(MA_LabelAxis0)=2,noLabel(MA_LabelAxis1)=2
		ModifyGraph/W=MiniAnaParentGraph axThick(MA_LabelAxis0)=0,axThick(MA_LabelAxis1)=0
		ModifyGraph/W=MiniAnaParentGraph freePos(MA_LabelAxis0)=0
		ModifyGraph/W=MiniAnaParentGraph freePos(MA_LabelAxis1)=0
		ModifyGraph/W=MiniAnaParentGraph axisEnab(MA_LabelAxis0)={0.9,0.95}
		ModifyGraph/W=MiniAnaParentGraph axisEnab(MA_LabelAxis1)={0.95,1}
		ModifyGraph/W=MiniAnaParentGraph axisEnab(left)={0,0.9}
		ModifyGraph/W=MiniAnaEventGraph mode(MA_LabelingWave0)=3,mode(MA_LabelingWave1)=3
		ModifyGraph/W=MiniAnaEventGraph marker(MA_LabelingWave0)=10,marker(MA_LabelingWave1)=10
		ModifyGraph/W=MiniAnaEventGraph rgb(MA_LabelingWave1)=(0,0,65280)
		ModifyGraph/W=MiniAnaEventGraph msize(MA_LabelingWave0)=2,msize(MA_LabelingWave1)=2
		ModifyGraph/W=MiniAnaEventGraph noLabel(MA_LabelAxis0)=2,noLabel(MA_LabelAxis1)=2
		ModifyGraph/W=MiniAnaEventGraph axThick(MA_LabelAxis0)=0,axThick(MA_LabelAxis1)=0
		ModifyGraph/W=MiniAnaEventGraph freePos(MA_LabelAxis0)=0
		ModifyGraph/W=MiniAnaEventGraph freePos(MA_LabelAxis1)=0
		ModifyGraph/W=MiniAnaEventGraph axisEnab(MA_LabelAxis0)={0.9,0.95}
		ModifyGraph/W=MiniAnaEventGraph axisEnab(MA_LabelAxis1)={0.95,1}
		ModifyGraph/W=MiniAnaEventGraph axisEnab(left)={0,0.9}
	endif
		
	MiniDispPeak = NaN
	MiniDispArea = NaN
	MiniDispRise = NaN
	MiniDispDecay = NaN
	
	t_MiniDaughterSetScale("")
End

Function t_MiniMainDisplay(ctrlName) : ButtonControl
	String ctrlName
	SVAR DisplayingWaveMini = root:Packages:MiniAna:DisplayingWaveMini
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
//	NVAR MiniDispPeak =  root:Packages:MiniAna:MiniDispPeak
//	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
//	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
//	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	EventWaveName = tWaveMini
	DisplayingWaveMini = tWaveMini
	
	ControlInfo/W=MiniAnaMain CheckSetDupLW_tab1
	If(V_value)
		String Label0 = tWaveMini + "_Label0"
		String Label1 = tWaveMini + "_Label1"
		If(Exists(Label0) == 0)
			Duplicate/O $tWaveMini, $Label0
			Wave wLabel0 = $Label0
			wLabel0 = NaN
		else
			Wave wLabel0 = $Label0			
		endif
		If(Exists(Label1) == 0)
			Duplicate/O $tWaveMini, $Label1
			Wave wLabel1 = $Label1
			wLabel1 = NaN		
		else
			Wave wLabel1 = $Label1			
		endif			
		RemoveFromGraph/W=MiniAnaDaughterGraph MA_LabelingWave0,MA_LabelingWave1
		RemoveFromGraph/W=MiniAnaParentGraph MA_LabelingWave0,MA_LabelingWave1
		RemoveFromGraph/W=MiniAnaEventGraph MA_LabelingWave0,MA_LabelingWave1
	endIf
	
	String fldrSav0= GetDataFolder(1)
//	SetDataFolder root:Packages:MiniAna
//	DoWindow/F MiniAnaDaughterGraph
//	String sdw = StringFromList(0, Wavelist("*", ";", "WIN:"))
//	DoWindow/F MiniAnaParentGraph
//	String tdw = StringFromList(0, Wavelist("*", ";", "WIN:"))
//	DoWindow/F MiniAnaEventGraph
//	String udw = StringFromList(0, Wavelist("*", ";", "WIN:"))
//	If(Strlen(sdw)>1)
//		RemoveFromGraph/W=MiniAnaDaughterGraph $sdw
//	endIf
//	If(Strlen(tdw)>1)
//		RemoveFromGraph/W=MiniAnaParentGraph $tdw
//	endIf
//	If(Strlen(udw)>1)
//		RemoveFromGraph/W=MiniAnaEventGraph $udw
//	endIf
//	SetDataFolder fldrSav0
	DoWindow/F MiniAnaDaughterGraph
	String sdw = StringFromList(0, Wavelist("*", ";", "WIN:"))
	DoWindow/F MiniAnaParentGraph
	String tdw = StringFromList(0, Wavelist("*", ";", "WIN:"))
	DoWindow/F MiniAnaEventGraph
	String udw = StringFromList(0, Wavelist("*", ";", "WIN:"))
	If(Strlen(sdw)>1)
		RemoveFromGraph/W=MiniAnaDaughterGraph $sdw
	endIf
	If(Strlen(tdw)>1)
		RemoveFromGraph/W=MiniAnaParentGraph $tdw
	endIf
	If(Strlen(udw)>1)
		RemoveFromGraph/W=MiniAnaEventGraph $udw
	endIf
	AppendToGraph/W=MiniAnaDaughterGraph $tWaveMini
	AppendToGraph/W=MiniAnaParentGraph $tWaveMini
	AppendToGraph/W=MiniAnaEventGraph $tWaveMini
//	Cursor/W=MiniAnaEventGraph A $tWaveMini 0
//	Cursor/W=MiniAnaEventGraph B $tWaveMini 0
//	Cursor/W=MiniAnaEventGraph C $tWaveMini 0
//	ControlInfo/W=MiniAnaMain CheckSetDupLW_tab1
	If(V_value)
//		Duplicate/O $tWaveMini root:Packages:MiniAna:MA_LabelingWave0, root:Packages:MiniAna:MA_LabelingWave1
		Wave MA_LabelingWave0 = root:Packages:MiniAna:MA_LabelingWave0
		Wave MA_LabelingWave1 = root:Packages:MiniAna:MA_LabelingWave1
//		fldrSav0= GetDataFolder(1)
//		SetDataFolder root:Packages:MiniAna
//		Wave MA_labelingWave0, MA_labelingWave1
		MA_labelingWave0 = wLabel0
		MA_labelingWave1 = wLabel1
		AppendToGraph/W=MiniAnaDaughterGraph/L=MA_LabelAxis0 MA_LabelingWave0
		AppendToGraph/W=MiniAnaDaughterGraph/L=MA_LabelAxis1 MA_LabelingWave1
		AppendToGraph/W=MiniAnaParentGraph/L=MA_LabelAxis0 MA_LabelingWave0
		AppendToGraph/W=MiniAnaParentGraph/L=MA_LabelAxis1 MA_LabelingWave1
		AppendToGraph/W=MiniAnaEventGraph/L=MA_LabelAxis0 MA_LabelingWave0
		AppendToGraph/W=MiniAnaEventGraph/L=MA_LabelAxis1 MA_LabelingWave1
//		SetDataFolder fldrSav0
//		DoUpdate
		ModifyGraph/W=MiniAnaDaughterGraph mode(MA_LabelingWave0)=3,mode(MA_LabelingWave1)=3
		ModifyGraph/W=MiniAnaDaughterGraph marker(MA_LabelingWave0)=10,marker(MA_LabelingWave1)=10
		ModifyGraph/W=MiniAnaDaughterGraph rgb(MA_LabelingWave1)=(0,0,65280)
		ModifyGraph/W=MiniAnaDaughterGraph msize(MA_LabelingWave0)=2,msize(MA_LabelingWave1)=2
		ModifyGraph/W=MiniAnaDaughterGraph noLabel(MA_LabelAxis0)=2,noLabel(MA_LabelAxis1)=2
		ModifyGraph/W=MiniAnaDaughterGraph axThick(MA_LabelAxis0)=0,axThick(MA_LabelAxis1)=0
		ModifyGraph/W=MiniAnaDaughterGraph freePos(MA_LabelAxis0)=0
		ModifyGraph/W=MiniAnaDaughterGraph freePos(MA_LabelAxis1)=0
		ModifyGraph/W=MiniAnaDaughterGraph lblPos(left)=0, lblPos(bottom)=0
		ModifyGraph/W=MiniAnaDaughterGraph lblLatPos(left)=0,lblLatPos(bottom)=0
		ModifyGraph/W=MiniAnaDaughterGraph axisEnab(MA_LabelAxis0)={0.9,0.95}
		ModifyGraph/W=MiniAnaDaughterGraph axisEnab(MA_LabelAxis1)={0.95,1}
		ModifyGraph/W=MiniAnaDaughterGraph axisEnab(left)={0,0.9}
		ModifyGraph/W=MiniAnaParentGraph mode(MA_LabelingWave0)=3,mode(MA_LabelingWave1)=3
		ModifyGraph/W=MiniAnaParentGraph marker(MA_LabelingWave0)=10,marker(MA_LabelingWave1)=10
		ModifyGraph/W=MiniAnaParentGraph rgb(MA_LabelingWave1)=(0,0,65280)
		ModifyGraph/W=MiniAnaParentGraph msize(MA_LabelingWave0)=2,msize(MA_LabelingWave1)=2
		ModifyGraph/W=MiniAnaParentGraph noLabel(MA_LabelAxis0)=2,noLabel(MA_LabelAxis1)=2
		ModifyGraph/W=MiniAnaParentGraph axThick(MA_LabelAxis0)=0,axThick(MA_LabelAxis1)=0
		ModifyGraph/W=MiniAnaParentGraph freePos(MA_LabelAxis0)=0
		ModifyGraph/W=MiniAnaParentGraph freePos(MA_LabelAxis1)=0
		ModifyGraph/W=MiniAnaParentGraph axisEnab(MA_LabelAxis0)={0.9,0.95}
		ModifyGraph/W=MiniAnaParentGraph axisEnab(MA_LabelAxis1)={0.95,1}
		ModifyGraph/W=MiniAnaParentGraph axisEnab(left)={0,0.9}
		ModifyGraph/W=MiniAnaEventGraph mode(MA_LabelingWave0)=3,mode(MA_LabelingWave1)=3
		ModifyGraph/W=MiniAnaEventGraph marker(MA_LabelingWave0)=10,marker(MA_LabelingWave1)=10
		ModifyGraph/W=MiniAnaEventGraph rgb(MA_LabelingWave1)=(0,0,65280)
		ModifyGraph/W=MiniAnaEventGraph msize(MA_LabelingWave0)=2,msize(MA_LabelingWave1)=2
		ModifyGraph/W=MiniAnaEventGraph noLabel(MA_LabelAxis0)=2,noLabel(MA_LabelAxis1)=2
		ModifyGraph/W=MiniAnaEventGraph axThick(MA_LabelAxis0)=0,axThick(MA_LabelAxis1)=0
		ModifyGraph/W=MiniAnaEventGraph freePos(MA_LabelAxis0)=0
		ModifyGraph/W=MiniAnaEventGraph freePos(MA_LabelAxis1)=0
		ModifyGraph/W=MiniAnaEventGraph axisEnab(MA_LabelAxis0)={0.9,0.95}
		ModifyGraph/W=MiniAnaEventGraph axisEnab(MA_LabelAxis1)={0.95,1}
		ModifyGraph/W=MiniAnaEventGraph axisEnab(left)={0,0.9}
	endif
	
	t_MiniDaughterSetScale("")
	
//	MiniDispPeak = NaN
//	MiniDispArea = NaN
//	MiniDispRise = NaN
//	MiniDispDecay = NaN
End


Function t_MiniTablePrep(ctrlName) : ButtonControl
	String ctrlName
//	DoAlert 2, "RecNum and SamplingHz must be defiend.\nAre you ready?"
//	If(V_flag != 1)
//		Abort
//	endIf
	String fldrsav0 = GetDataFolder(1)
	SetDatafolder root:Packages:MiniAna:
	Variable labelnum = 0
	ControlInfo/W=MiniAnaMain CheckSerial_tab3
	If(V_value)
		If(Exists("Serial") != 1)
			Make/N=0 Serial
		endif
		AppendToTable/W=MiniAnaTable#T0 Serial
		SetDimLabel 1,labelnum,Serial,MiniLb2D
		labelnum += 1
	endIf
		
	ControlInfo/W=MiniAnaMain CheckWaveName_tab3
	If(V_value)
		If(Exists("wvName") != 1)
			Make/T/N=0 wvName
		endif
		AppendToTable/W=MiniAnaTable#T0 wvName
		SetDimLabel 1,labelnum,wvName,MiniLb2D
		labelnum += 1
	endIf
	
	ControlInfo/W=MiniAnaMain CheckXLock_tab3
	If(V_value)
		If(Exists("XLock") != 1)
			Make/N=0 XLock
		endif
		AppendToTable/W=MiniAnaTable#T0 XLock
		SetDimLabel 1,labelnum,XLock,MiniLb2D
		labelnum += 1
	endIf
	
	ControlInfo/W=MiniAnaMain CheckALockedX_tab3
	If(V_value)
		If(Exists("ALocked") !=1)
			Make/N=0 ALocked
		endif
		AppendToTable/W=MiniAnaTable#T0 ALocked
		SetDimLabel 1,labelnum,ALocked,MiniLb2D
		labelnum += 1
	endIf
	
	ControlInfo/W=MiniAnaMain CheckInitialX_tab3
	If(V_value)
		If(Exists("InitialX") != 1)
			Make/N=0 InitialX
		endif
		AppendToTable/W=MiniAnaTable#T0 InitialX
		SetDimLabel 1,labelnum,InitialX,MiniLb2D
		labelnum += 1
	endIf

	ControlInfo/W=MiniAnaMain CheckIsolateTag_tab3
	If(V_value)
		If(Exists("Isolate") != 1)
			Make/N=0 Isolate
		endif
		AppendToTable/W=MiniAnaTable#T0 Isolate
		SetDimLabel 1,labelnum,Isolate,MiniLb2D
		labelnum += 1
	endIf
	
	ControlInfo/W=MiniAnaMain CheckInterEventInterval_tab3
	If(V_value)
		If(Exists("IEI") != 1)
			Make/N=0 IEI
		endIf
		AppendToTable/W=MiniAnaTable#T0 IEI
		SetDimLabel 1,labelnum,IEI,MiniLb2D
		labelnum += 1
	endIf

	ControlInfo/W=MiniAnaMain CheckBase_tab3	
	If(V_value)
		If(Exists("Base") != 1)
			Make/N=0 Base
		endif
		AppendToTable/W=MiniAnaTable#T0 Base
		SetDimLabel 1,labelnum,Base,MiniLb2D
		labelnum += 1
	endIf

	ControlInfo/W=MiniAnaMain CheckPeak_tab3	
	If(V_value)
		If(Exists("Peak") != 1)
			Make/N=0 Peak
		endif
		AppendToTable/W=MiniAnaTable#T0 Peak
		SetDimLabel 1,labelnum,Peak,MiniLb2D
		labelnum += 1
	endIf

	ControlInfo/W=MiniAnaMain CheckArea_tab3	
	If(V_value)
		If(Exists("AreaUC") != 1)
			Make/N=0 AreaUC
		endif
		AppendToTable/W=MiniAnaTable#T0 AreaUC
		SetDimLabel 1,labelnum,AreaUc,MiniLb2D
		labelnum += 1
	endIf

	ControlInfo/W=MiniAnaMain CheckDecay_tab3	
	If(V_value)
		If(Exists("Decay") != 1)
			Make/N=0 Decay
		endif
		AppendToTable/W=MiniAnaTable#T0 Decay
		SetDimLabel 1,labelnum,Decay,MiniLb2D
		labelnum += 1
	endIf
	
	ControlInfo/W=MiniAnaMain CheckRise_tab3	
	If(V_value)
		If(Exists("Rise") != 1)
			Make/N=0 Rise
		endif
		AppendToTable/W=MiniAnaTable#T0 Rise
		SetDimLabel 1,labelnum,Rise,MiniLb2D
		labelnum += 1
	endIf
	
	ControlInfo/W=MiniAnaMain CheckExpRecNum_tab3	
	If(V_value)
		If(Exists("RecNum") != 1)
			Make/T/N=0 RecNum
		endif
		AppendToTable/W=MiniAnaTable#T0 RecNum
		SetDimLabel 1,labelnum,RecNum,MiniLb2D
		labelnum += 1
	endIf
	
	ControlInfo/W=MiniAnaMain CheckSamplingHz_tab3	
	If(V_value)
		If(Exists("Sampling") != 1)
			Make/T/N=0 Sampling
		endif
		AppendToTable/W=MiniAnaTable#T0 Sampling
		SetDimLabel 1,labelnum,Sampling,MiniLb2D
		labelnum += 1
	endIf
	
	ControlInfo/W=MiniAnaMain CheckParentCurrent_tab3
	If(V_value)
		If(Exists("PCurrent") != 1)
			Make/N=0 PCurrent
		endif
		AppendToTable/W=MiniAnaTable#T0 PCurrent
		SetDimLabel 1,labelnum,PCurrent,MiniLb2D
		labelnum += 1
	endIf
	
	ControlInfo/W=MiniAnaMain CheckError_tab3
	If(V_value)
		If(Exists("Error") != 1)
			Make/N=0 Error
		endif
		AppendToTable/W=MiniAnaTable#T0 Error
		SetDimLabel 1,labelnum,Error,MiniLb2D
		labelnum += 1
	endIf
	
	Redimension/N=(0,16) MiniLb2D
	SetDataFolder fldrsav0
End

Function t_MiniAnaWavePrep(ctrlName) : ButtonControl
	String ctrlName
	
	t_dispwl("")
	
	String SFL = ""
	SFL = StringFromList(0, Wavelist("*", ";", "WIN:"))
	Cursor A $SFL leftx($SFL)
	
	t_subCursol_tWL("")
	t_LowPassFilterWL("")
	t_CleartWL("")
	t_gettwavelist("")
	t_MiniGetWaveList("")
End

Function t_MiniAutoSearch(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR ExpRecNum = root:Packages:MiniAna:ExpRecNum
	SVAR SamplingHz = root:Packages:MiniAna:SamplingHz
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	NVAR SetMiniPCurrent = root:Packages:MiniAna:SetMiniPCurrent
	NVAR SetMiniArtifactX = root:Packages:MiniAna:SetMiniArtifactX
	NVAR FitTimeInitial = root:Packages:MiniAna:SetMiniFitTimeInitial
	NVAR FitTimeFinish = root:Packages:MiniAna:SetMiniFitTimeFinish
	NVAR TimeInitial = root:Packages:MiniAna:SetMiniTimeInitial
	NVAR TimeFinish = root:Packages:MiniAna:SetMiniTimeFinish
	NVAR PeakAmp = root:Packages:MiniAna:DetectPeakAmp
	NVAR TightBack = root:Packages:MiniAna:DetecttightBack
	NVAR Tightness = root:Packages:MiniAna:Detecttightness
	NVAR DetectBox = root:Packages:MiniAna:DetectSmoothingBox
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	NVAR DetectArea = root:Packages:MiniAna:DetectArea
	NVAR DetectAreaDecayRange = root:Packages:MiniAna:DetectAreaDecayRange

	String SFL = ""
	String sdw = tWaveMini
	
	Wave twl = root:Packages:MiniAna:Mini_WavelistWave
	Wave dw = $sdw
	Wave/T wList = root:Packages:MiniAna:Mini_WaveListWave
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave IEI = root:Packages:MiniAna:IEI
	Wave Base = root:Packages:MiniAna:Base
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUC = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Wave/T Sampling = root:Packages:MiniAna:Sampling
	Wave PCurrent = root:Packages:MiniAna:PCurrent
	Wave Error = root:Packages:MiniAna:Error
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	Wave luw0 = $(tWaveMini + "_Label0")
	Wave luw1 = $(tWaveMini + "_Label1")

	Variable i, j = 0
	Variable keys = 0	
	keys = GetKeyState(0)
	
	ControlInfo/W=MiniAnaMain Popup_Fitting_tab1
	String FittingFunction = S_Value
	String Indbasefit = sdw + "_basefit"	
	Duplicate/O $sdw, w_fitdup, $Indbasefit
	Wave w_fitdup
	Wave basefit = $Indbasefit
	
	ControlInfo/W=MiniAnaMain Popup_AnalysisMode_tab1
	String Check_Sponta = S_Value
	If(StringMatch(Check_Sponta, "Mini or Sponta"))
		If(StringMatch(FittingFunction, "none"))
			w_fitdup = 0
		else
			Variable Meandw = Mean(dw)
			w_fitdup = Meandw
		endif
	else
		Variable pfitinitial = x2pnt(dw, FitTimeInitial)
		Variable pfitfinish = x2pnt(dw, FitTimeFinish)
		StrSwitch(FittingFunction)
			case "none":
				w_fitdup = 0
				break
			case "line":
				CurveFit/Q/NTHR=0 line dw[pfitinitial,pfitfinish]
				w_fitdup = K0 + K1*x
				w_fitdup[0, (pfitinitial-1)] = NaN
				break
			case "dblexp_XOffset":
				CurveFit/Q/NTHR=0 dblexp_XOffset  dw[pfitinitial,pfitfinish]
				w_fitdup = K0+K1*exp(-(x-FitTimeInitial)/K2)+K3*exp(-(x-FitTimeInitial)/K4)
				w_fitdup[0, (pfitinitial-1)] = NaN
				break
			default:
				break
		endSwitch
	endif

	If(FindListItem("w_fitdup", WaveList("*", ";", "WIN:MiniAnaDaughterGraph"))==-1)
		AppendToGraph/w= MiniAnaDaughterGraph w_fitdup
	endIf

	String tempfitname = "fit_"+sdw
	If(FindListItem(tempfitname, WaveList("*", ";", "WIN:MiniAnaDaughterGraph"))==!-1)
		RemoveFromGraph/w= MiniAnaDaughterGraph $tempfitname
	endIf
	ModifyGraph/W=MiniAnaDaughterGraph rgb(w_fitdup)=(0,0,65280)
	basefit = dw - w_fitdup

	If(keys & 4) // If shift key is pressed
		Abort
	endif
	
	//PeakFindings
	ControlInfo/W=MiniAnaMain PopupPeakDetect_tab2
	Variable PeakPolarity = V_Value
	Variable PolarizedPA
	Switch(V_Value)
		case 1:
			PolarizedPA = -PeakAmp
			break
		default:
			break
	endSwitch

	If(StringMatch(Check_Sponta, "Mini or Sponta"))
		FindLevels/Q/B=(DetectBox) basefit, PolarizedPA
	else
		FindLevels/Q/B=(DetectBox)/R=(TimeInitial, TimeFinish) basefit, PolarizedPA
	endif	
	WaveStats/Q/M=1 W_FindLevels
	Variable npnts_FLV = numpnts(W_FindLevels)
	Wave W_FindLevels
	Duplicate/O W_FindLevels, W_PeakXLoc
	i = 0
	do
		Variable FLI = W_FindLevels[i] - TightBack *deltax(dw)
		Variable FLF = W_FindLevels[i+1] + Tightness *deltax(dw)
		Wavestats/Q/M=1/R=(FLI, FLF) basefit
		ControlInfo/W=MiniAnaMain PopupPeakDetect_tab2
		Switch(V_Value)
			case 1:
				If(abs(V_min) > abs(PeakAmp))
					W_PeakXLoc[i] = V_minloc
				else
					W_PeakXLoc[i] = NaN
				endIf
				break
			case 2:
				If(abs(V_max) > abs(PeakAmp))
					W_PeakXLoc[i] = V_maxloc
				else
					W_PeakXLoc[i] = NaN
				endIf
				break
			case 3:
				DoAlert 0, "UnderConstruction"
				Abort
				break
			default:
				break
		endSwitch
		i += 1
		W_PeakXLoc[i] = NaN
	while(i+1 <= npnts_FLV)

	// removing the overlapping timestamps
	i = 0
	do
		If(numtype(W_PeakXLoc[i]) == 0)
			If(W_PeakXLoc[i]==W_PeakXLoc[i+1])
				DeletePoints i, 1, W_PeakXLoc
			else
				i+=1
			endIf
		else
			DeletePoints i, 1, W_PeakXLoc
		endIf
		Wavestats/Q/M=1 W_PeakXLoc
	while(i< numpnts(W_PeakXLoc))

	// InitialX
	Duplicate/O W_PeakXLoc, W_InitialXLoc
	Duplicate/O $sdw root:Packages:MiniAna:line_a, root:Packages:MiniAna:line_b, root:Packages:MiniAna:line_c
	Wave line_a = root:Packages:MiniAna:line_a
	Wave line_b = root:Packages:MiniAna:line_b
	Wave line_c = root:Packages:MiniAna:line_c
	i=0
	Variable npntsXLock = numpnts(W_PeakXLoc)
	do
		CurveFit/Q/M=2/W=0 line, basefit((W_PeakXLoc[i]-0.0003), (W_PeakXLoc[i]))
		Wave W_coef
		line_a = W_coef[0] + x*W_coef[1]
		CurveFit/Q/M=2/W=0 line, basefit((W_PeakXLoc[i]-0.002), (W_PeakXLoc[i]-0.001))
		Wave W_coef
		line_b = W_coef[0] + x*W_coef[1]
		line_c = line_a - line_b
		FindLevel/Q line_c, 0
		W_InitialXLoc[i] = V_levelX
		i+=1
	while(i<=npntsXLock)
	
		
	// area
	Duplicate/O W_PeakXLoc, W_Area
	i = 0
	npntsXLock = numpnts(W_PeakXLoc)

	do
		Variable area_a = (basefit(W_PeakXLoc[i]+DetectAreaDecayRange)-basefit(W_InitialXLoc[i]))/((W_PeakXLoc[i]+DetectAreaDecayRange)-W_InitialXLoc[i])
		Variable area_b = 0.5*(basefit(W_InitialXLoc[i])+basefit(W_PeakXLoc[i]+DetectAreaDecayRange) - (W_InitialXLoc[i]+W_PeakXLoc[i]+DetectAreaDecayRange)*area_a)
		Duplicate/O basefit root:Packages:MiniAna:MiniArea0, root:Packages:MiniAna:MiniArea1
		Wave MiniArea0 = root:Packages:MiniAna:MiniArea0
		Wave MiniArea1 = root:Packages:MiniAna:MiniArea1
		MiniArea0 = area_a*x+area_b
		MiniArea1 = basefit - MiniArea0
		W_Area[i] = Area(MiniArea1, W_InitialXLoc[i], (W_PeakXLoc[i]+DetectAreaDecayRange))
		i+=1
	while(i <= npntsXLock)
	
	//
	i = 0
	do
		If(ABS(W_Area[i])>=ABS(DetectArea))
			i+=1
		else
			DeletePoints i, 1, W_Area, W_PeakXLoc, W_InitialXLoc
		endIf
		Wavestats/Q/M=1 W_PeakXLoc
	while(i<= V_npnts)
	
	i=0
	lw0 = NaN
	lw1 = NaN
	luw0 = NaN
	luw1 = NaN
	do
		If(numtype(W_PeakXLoc[i]) !=2)
			Cursor/W=MiniAnaDaughterGraph A $sdw W_PeakXLoc[i]
			DoWindow/F MiniAnaDaughterGraph
			lw0[pcsr(A)] = 1
			lw1 = lw0
			luw0 = lw0
			luw1 = lw1
		endIf
		i += 1
	while(i<=numpnts(W_PeakXLoc))
	
	i=0
	do
		If((W_PeakXLoc[i+1]-W_PeakXLoc[i])<0.1*IsoCriteria)
			Cursor/W=MiniAnaDaughterGraph A $sdw W_PeakXLoc[i]
			lw1[pcsr(A)] = NaN
			Cursor/W=MiniAnaDaughterGraph A $sdw W_PeakXLoc[i]
			lw1[pcsr(A)] = NaN
			luw1 = lw1
		else
			If((W_PeakXLoc[i+1]-W_PeakXLoc[i])<0.9*IsoCriteria)
			Cursor/W=MiniAnaDaughterGraph A $sdw W_PeakXLoc[i]
			lw1[pcsr(A)] = NaN
			luw1 = lw1
			endIf
		endIf
		i+=1
	while(i+1<V_npnts)
	
	
	// append to table
	// T0 wave list
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0
	
	
	i=0
	do
		j = 0
		Variable npnts = numpnts(Serial)+1
		do
			SFL = StringFromList(j, T0WL)
			If(Strlen(SFL)<1)
				break
			endIf
			Insertpoints npnts, 1, $("root:Packages:MiniAna:" + SFL)
			j += 1
		while(1)
		
		//wvName
		wvName[npnts] = sdw
		
		//XLock
		XLock[npnts] = W_PeakXLoc[i]
		
		//ALocked
		ControlInfo/W=MiniAnaMain CheckALockedX_tab3
		If(V_value)
			ALocked[npnts] = XLock[npnts] - SetMiniArtifactX
		endIf
		
		//InitialX
		InitialX[npnts] = W_InitialXLoc[i]
			
		//Isolate
		ControlInfo/W=MiniAnaMain CheckIsolateTag_tab3
		If(V_value)
			If(lw1(W_PeakXLoc[i]) == 1)
				Isolate[npnts] = 1
			else
				Isolate[npnts] = 0
			endIf
		endIf			
		
		//Base
		Base[npnts] = Mean(basefit, (InitialX[npnts]-deltax(basefit)), (InitialX[npnts] + deltax(basefit)))

		//Peak
		ControlInfo/W=MiniAnaMain CheckPeak_tab3	
		If(V_value)
			Peak[npnts] = ABS(basefit(XLock[npnts]) - Base[npnts])
		endIf
	
		
		//Area
		ControlInfo/W=MiniAnaMain CheckArea_tab3	
		If(V_value)
			AreaUC[npnts] = W_Area[i]
		endIf
		
		
		//Decay
		ControlInfo/W=MiniAnaMain CheckDecay_tab3	
		If(V_value)
			If(i<numpnts(W_PeakXLoc)-1)
				If((W_PeakXLoc[i+1]-W_PeakXLoc[i])>=DetectAreaDecayRange+0.001)
					CurveFit/Q/NTHR=0 exp_XOffset  basefit(W_PeakXLoc[i], W_PeakXLoc[i]+DetectAreaDecayRange)
					If(W_coef[2]>0&&W_coef[2]<0.02)
						Decay[npnts] = W_coef[2]
					else
						Decay[npnts] = NaN
					endIf
				else
					Decay[npnts] = NaN
				endIf
			else
				CurveFit/Q/NTHR=0 exp_XOffset  basefit(W_PeakXLoc[i], W_PeakXLoc[i]+DetectAreaDecayRange)
				If(W_coef[2]>0&&W_coef[2]<0.02)
					Decay[npnts] = W_coef[2]
				else
					Decay[npnts] = NaN
				endIf
			endIf
		endIf
		
		//Rise
		ControlInfo/W=MiniAnaMain CheckRise_tab3	
		If(V_value)
			Variable RTXLock0, RTXLock1
			FindLevel/Q/R=(W_InitialXLoc[i], W_PeakXLoc[i]) basefit, basefit(InitialX[npnts])+0.1*(basefit(XLock[npnts])-basefit(InitialX[npnts]))
			RTXLock0 = V_LevelX
			FindLevel/Q/R=(W_InitialXLoc[i], W_PeakXLoc[i]) basefit, basefit(InitialX[npnts])+0.9*(basefit(XLock[npnts])-basefit(InitialX[npnts]))
			RTXLock1 = V_LevelX
			If((RTXLock1-RTXLock0)>0)
				Rise[npnts] = RTXLock1-RTXLock0
			else
				Rise[npnts] = NaN
			endIf
		endIf
		
		//RecNum
		ControlInfo/W=MiniAnaMain CheckExpRecNum_tab3	
		If(V_value)
			RecNum[npnts] =  ExpRecNum
		endIf
			
		//Sampling
		ControlInfo/W=MiniAnaMain CheckSamplingHz_tab3	
		If(V_value)
			Sampling[npnts] = SamplingHz
		endIf
			
		//PCurrent
		ControlInfo/W=MiniAnaMain CheckParentCurrent_tab3
		If(V_value)
			PCurrent[npnts] = SetMiniPCurrent
		endIf

		//Error
		ControlInfo/W=MiniAnaMain CheckError_tab3
		If(V_value)
			If(XLock[npnts]<InitialX[npnts])
				Error[npnts] = 1
			else
				If(Rise[npnts]<0)
					Error[npnts] = 1
				else
					Error[npnts] = 0
				endIf
			endIf
		endIf
	
		//Sorting
		fldrsav0 = GetDataFolder(1)
		SetDataFolder root:Packages:MiniAna:
		String ForSort1 = Wavelist("*", ",", "WIN:MiniAnaTable#T0")
		String ForSort2 = ForSort1[0, (Strlen(T0WL)-1)]
		String t = "Sort/A {wvName, XLock, Serial}," + ForSort2
		Execute t
		SetDataFolder fldrsav0
		
		
		//Serial and IEI
		FindLevel/P/Q Serial, 0
		Variable InsertingPoint = V_LevelX
		Serial[p,] = x + 1
		
		//IEI
		ControlInfo/W=MiniAnaMain CheckInterEventInterval_tab3
		If(V_value)
			If(i !=0)
				If(StringMatch(wvName[InsertingPoint], wvName[InsertingPoint-1]))
					IEI[InsertingPoint] = W_PeakXLoc[i] - W_PeakXLoc[i-1]
				else
					IEI[InsertingPoint] = NaN
				endIf
			else
				IEI[InsertingPoint] = NaN
			endIf		
		endIf
		
		t_Update_MiniLb2D()
		
		npnts = numpnts(Serial)
		If(npnts <10)
			ListBox Lb0, win=MiniAnaTable, row=-1, selRow= npnts-1
		else
			ListBox Lb0, win=MiniAnaTable, row=(npnts - 10), selRow= npnts-1
		endif
		
	i+=1
	while(i<numpnts(W_PeakXLoc))
	
//	t_Update_MiniLb2D()
End

Function t_MiniAllSearch(ctrlName) : ButtonControl
	String ctrlName
	
	Variable i = 0
	Wave Mini_WaveListWave = root:Packages:MiniAna:Mini_WaveListWave
	
	For(i = 0; i < numpnts(Mini_WaveListWave); i += 1)
		t_MiniAutoSearch("")
		t_MiniD_NextSweep("")
	endfor
end

Proc t_RecoveryMiniAnaDaughterGraph(ctrlName) : ButtonControl
	String ctrlName
	String cmd = "DoWindow/R/K MiniAnaDaughterGraph"
	Execute/P/Q cmd
	cmd = "MiniAnaDaughterGraph()"
	Execute/P/Q cmd
endMacro

Function t_PopMenuProcMiniSet(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	Switch (popNum)
		case 1:
			GroupBox GroupTimeWindow_tab1 disable = 0, win = MiniAnaMain
			SetVariable SetInitialTime_tab1 disable = 0, win = MiniAnaMain
			SetVariable SetFinishTime_tab1 disable = 0, win = MiniAnaMain
			break
		case 2:
			GroupBox GroupTimeWindow_tab1 disable = 2, win = MiniAnaMain
			SetVariable SetInitialTime_tab1 disable = 2, win = MiniAnaMain
			SetVariable SetFinishTime_tab1 disable = 2, win = MiniAnaMain
			
			NVAR TimeInitial = root:Packages:MiniAna:SetMiniTimeInitial
			NVAR TimeFinish = root:Packages:MiniAna:SetMiniTimeFinish
			SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
			Wave srcw = $tWaveMini
			If(WaveExists(srcw))			
				TimeInitial = leftx(srcw)
				TimeFinish = rightx(srcw)
			endIf
			
			break
		default:
			break
	endSwitch
End

Function t_MAFieldCheck(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	StrSwitch (ctrlName)
		case "CheckPeak_tab3":
			If(checked)
//				PopupMenu PopupPeakDetect_tab2 disable=0, win = MiniAnaMain
//				SetVariable SetPeakAmplitude_tab2 disable=0, win = MiniAnaMain
//				SetVariable SetPeakAmplitude_tab2 disable=0, win = MiniAnaMain				
			else
//				PopupMenu PopupPeakDetect_tab2 disable=2, win = MiniAnaMain
//				SetVariable SetPeakAmplitude_tab2 disable=2, win = MiniAnaMain
//				SetVariable SetPeakAmplitude_tab2 disable=2, win = MiniAnaMain
			endIf
			break
		default:
			break
	endSwitch
End

Function t_MiniCheck_tab1(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	If(StringMatch(ctrlName, "CheckSetDupEW_tab1"))
		Switch (checked)
			case 0:
				CheckBox CheckSetDisplayEW_tab1 disable=2,value=0, win = MiniAnaMain
				break
			case 1:
				CheckBox CheckSetDisplayEW_tab1 disable=0, win = MiniAnaMain
				break
			default:
				break
		endSwitch
	endIf
End
///////////////////////////////////////////////////////////////////////////
//AnaTable
Function t_MiniAnaTable()
	NewPanel/N=MiniAnaTable /W=(183,829,1585,1116)
	Button BtTablePrepMATable,pos={2,3},size={70,20}, proc=t_MiniTablePrep,title="TablePrep"
	Button BtEditT0MiniAnaTable,pos={2,23},size={50,20},proc=t_EditT0MiniAnaTable,title="EditT0"
	Button BtIEI02NaN,pos={53,23},size={70,20},proc=t_IEI02NaN,title="IEI02NaN"
	Button BtMiniEventSum,pos={153,4},size={70,20},proc=t_MiniEventSum,title="EventSum"
	Button BtMiniEventSumIniX,pos={153,25},size={70,20},proc=t_MiniEventSumIniX,title="EventSumIX"
	Button BtMiniEventSumAvg,pos={153,46},size={70,20},proc=t_MiniEventSumAvg,title="EventSumAv"
	Button BtMiniEventSumIniXSave,pos={223,25},size={70,20},proc=t_MiniSaveSumIniX,title="SaveSumIX"
	Button BtSaveTable,pos={2,43},size={70,20},proc=t_MiniSaveTable,title="SaveTable"
	Button BtMeanPeak,pos={2,63},size={70,20},proc=t_MiniAnaMeanPeak,title="MeanPeak"
	Button BtDeletetWaveMiniRecord,pos={539,91},size={100,20},proc=t_DeletetWaveMiniRecord,title="Delete tWaveMini"
	Button BtDeleteSelectedRecord,pos={640,91},size={100,20},proc=t_DeleteSelectedRecord,title="Delete Selected"
	Button BtMiniTableDelete,pos={742,91},size={90,20},proc=t_MiniAnaTableDeleteAllPoint,title="DeleteAllPoints"
	Button BtMiniAnaTable_ShowT0,pos={252,6},size={50,20},proc=t_MA_ShowT0,title="T0"
	Button Bt_MiniAnaTable_ListBox,pos={310,6},size={50,20},proc=t_MA_ListBox,title="ListBox"
	ListBox Lb0,pos={3,112},size={1395,188},frame=2,listWave=root:Packages:MiniAna:MiniLb2D
	ListBox Lb0,row= 17,mode= 1,selRow= 0
	ShowTools/A
	DefineGuide UGH0={FT,116}
	Edit/W=(77,216,745,301)/FG=(FR,FB,FR,FB)/HOST=#  as "MiniAnaTable"
	ModifyTable format=1, width=70
	ModifyTable statsArea=85
	RenameWindow #,T0
	SetActiveSubwindow ##
end

Function t_EditT0MiniAnaTable(ctrlName) : ButtonControl
	String ctrlName
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String tWavelist = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	Variable i = 0
	Edit
	String SFL
	do
		SFL = StringFromList(i, tWavelist)
		If(Strlen(SFL) < 1)
			break
		endIf
		AppendToTable $SFL
		i += 1
	while(1)
	SetDataFolder fldrsav0
	
	t_IEI02NaN("")
End

Function t_MiniSaveTable(ctrlName) : ButtonControl
	String ctrlName

	SVAR ExpRecNum = root:Packages:MiniAna:ExpRecNum
	Print ExpRecNum
	SaveTableCopy/T=2 as ExpRecNum
End

Function t_IEI02NaN(ctrlName) : ButtonControl
	String ctrlName
	Wave dw = root:Packages:MiniAna:IEI
	WaveStats/Q dw
//	Print V_npnts, V_numNans, V_numINFs
	Variable n = 0
	Variable m = V_npnts + V_numNans + V_numINFs	
	do
		If(dw[n]==0)
			dw[n] = NaN
		endif
		n=n+1
	while(n<=m)
End

Function t_MiniEventSum(ctrlName) : ButtonControl
	String ctrlName
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Variable i = 0
	Variable j = 1
	Variable npnts = numpnts(Serial)
	Duplicate/O $wvName[0] $RecNum[0]
	Wave avgEventWave = $RecNum[0]
	Variable IsoPoint = x2pnt($wvName[0], IsoCriteria)*2
	avgEventWave[0,IsoPoint]= 0
//	avgEventWave[IsoPoint+1, ] = NaN
	Redimension/N= (IsoPoint) avgEventWave
	do
		If(Isolate[i])
			Wave incrimentWave = $wvName[i]
			Variable ip = x2pnt($wvName[i], XLock[i]) - 0.2*IsoPoint
			Variable fp = x2pnt($wvName[i], XLock[i]) + 1.8*IsoPoint
			avgEventWave[p, IsoPoint] += incrimentWave[p+ip]
			j += 1
		endIf
		i+=1
	while(i<npnts)
	avgEventWave = avgEventWave/j
	Rename avgEventWave, $("w_"+RecNum[0]+"_"+Num2str(j))
	Display avgEventWave
	ModifyGraph width = 141.732,height=141.32
End

Function t_MiniEventSumIniX(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Variable i = 0
	Variable j = 1
	Variable npnts = numpnts(Serial)
	Duplicate/O $wvName[0] $RecNum[0]
	Wave avgEventWave = $RecNum[0]
	Variable IsoPoint = x2pnt($wvName[0], IsoCriteria)*2
	avgEventWave[0,IsoPoint]= 0
//	avgEventWave[IsoPoint+1, ] = NaN
	Redimension/N= (IsoPoint) avgEventWave
	do
		If(Isolate[i])
			Wave incrimentWave = $wvName[i]
			Variable ip = x2pnt($wvName[i], InitialX[i]) - 0.2*IsoPoint
			Variable fp = x2pnt($wvName[i], InitialX[i]) + 1.8*IsoPoint
			avgEventWave[p, IsoPoint] += incrimentWave[p+ip]
			j += 1
		endIf
		i+=1
	while(i<npnts)
	avgEventWave = avgEventWave/j
	Rename avgEventWave, $("w_"+RecNum[0]+"_IX"+"_"+Num2str(j))
	Display avgEventWave
	ModifyGraph width = 141.732,height=141.32

End

Function t_MiniSaveSumIniX(ctrlName) : ButtonControl
	String ctrlName

	Wave Serial = root:Packages:MiniAna:Serial
	Wave Isolate = root:Packages:MiniAna:Isolate	
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Variable i = 0
	Variable j = 1
	Variable npnts = numpnts(Serial)
	
	do
		If(Isolate[i])
			j += 1
		endIf
		i += 1
	while(i < npnts)

	Wave srcW = $("w_"+RecNum[0]+"_IX"+"_"+Num2str(j))
	Save/T srcW as ("w_"+RecNum[0]+"_IX"+"_"+Num2str(j))
End

Function t_MiniAnaMeanPeak(ctrlName) : ButtonControl
	String ctrlName
	
	WaveStats :Packages:MiniAna:Peak
End

Function t_MiniEventSumAvg(ctrlName) : ButtonControl
	String ctrlName
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Variable i = 0
	Variable j = 1
	Variable npnts = numpnts(Serial)
	Duplicate/O $wvName[0] $RecNum[0]
	Wave avgEventWave = $RecNum[0]
	Variable IsoPoint = x2pnt($wvName[0], IsoCriteria)*2
	avgEventWave[0,IsoPoint]= 0
//	avgEventWave[IsoPoint+1, ] = NaN
	Redimension/N= (IsoPoint) avgEventWave
	do
		If(Isolate[i])
			Wave incrimentWave = $wvName[i]
			Variable ip = x2pnt($wvName[i], (1*XLock[i] + 1*InitialX[i])/2) - 0.2*IsoPoint
			Variable fp = x2pnt($wvName[i], (1*XLock[i] + 1*InitialX[i])/2) + 1.8*IsoPoint
			avgEventWave[p, IsoPoint] += incrimentWave[p+ip]
			j += 1
		endIf
		i+=1
	while(i<npnts)
	avgEventWave = avgEventWave/j
	Rename avgEventWave, $("w_"+RecNum[0]+"_Avg_"+Num2str(j))
	Display avgEventWave
	ModifyGraph width = 141.732,height=141.32
End

Function t_DeletetWaveMiniRecord(ctrlName) : ButtonControl
	String ctrlName
	Variable i = 0
	For(i = 0; i<10; i +=1)
		t_DeletetWaveMiniRecordSingle()
	endfor
	t_Update_MiniLb2D()
end

Function t_DeletetWaveMiniRecordSingle()
	String ctrlName
	Variable i = 0
	Variable j = 0
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Variable n = numpnts(Serial)
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	String SFL
	
	//T0 Wavelist
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0
	
	fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	j = 0
	do
		If(StringMatch(wvName[j], tWaveMini))
			i = 0
			do
				SFL = StringFromList(i, T0WL)
				If(Strlen(SFL)<1)
					i += 10000
				else
					Deletepoints j, 1, $SFL
				endIf
				i += 1
			while(i < 10000)
		endIf
		j += 1
	while(j <= n)
	SetDataFolder fldrsav0
	
	t_Update_MiniLb2D()
	
	Variable npnts = numpnts(Serial)
	If(npnts <10)
		ListBox Lb0, win=MiniAnaTable, row=-1, selRow= npnts-1
	else
		ListBox Lb0, win=MiniAnaTable, row=(npnts - 10), selRow= npnts-1
	endif
End


Function t_DeleteSelectedRecord(ctrlName) : ButtonControl
	String ctrlName
	Variable pfirst = Str2Num(StringFromList(0, StringByKey("SELECTION", TableInfo("MiniAnaTable#T0", -2), ":"), ","))
	Variable plast = Str2Num(StringFromList(2, StringByKey("SELECTION", TableInfo("MiniAnaTable#T0", -2), ":"), ","))
	Variable i = 0
	String SFL
	
	//T0 Wavelist
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0
	do
		SFL = StringFromList(i, T0WL)
		If(Strlen(SFL)<1)
			break
		endIf
		Deletepoints pfirst, (plast-pfirst+1), $("root:Packages:MiniAna:" + SFL)
		i += 1
	while(1)
	
	Wave Serial = root:Packages:MiniAna:Serial
	Serial[p,] = x + 1
	
//	Variable InsertingPoint = DeletingPoint
//	EventSerial = InsertingPoint + 1
//	Variable point = InsertingPoint
	
	t_Update_MiniLb2D()
	
	Variable npnts = numpnts(Serial)
	If(npnts <10)
		ListBox Lb0, win=MiniAnaTable, row=-1, selRow= npnts-1
	else
		ListBox Lb0, win=MiniAnaTable, row=(npnts - 10), selRow= npnts-1
	endif
End

Function t_MiniAnaTableDeleteAllPoint(ctrlName) : ButtonControl
	String ctrlName
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	Wave Serial = root:Packages:MiniAna:Serial
	String tWavelist = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	Variable i = 0
	DoAlert 2, "All data in this table will be deleted.\nAre you going to  continue?"
	If(V_Flag != 1)
		Abort
	endIf
	
	String SFL
	Variable n = numpnts(Serial)
	do
		SFL = StringFromList(i, tWavelist)
		If(Strlen(SFL) < 1)
			break
		endIf
		DeletePoints 0, n, $SFL
		i += 1
	while(1)
	SetDataFolder fldrsav0
	
	t_Update_MiniLb2D()
End
	
Function t_Update_MiniLb2D()
	Variable vnpnts = numpnts(root:Packages:MiniAna:Serial)
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave IEI = root:Packages:MiniAna:IEI
	Wave Base = root:Packages:MiniAna:Base
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUC = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Wave/T Sampling = root:Packages:MiniAna:Sampling
	Wave PCurrent = root:Packages:MiniAna:PCurrent
	Wave Error = root:Packages:MiniAna:Error
	Wave/T MiniLb2D = root:Packages:MiniAna:MiniLb2D
	Redimension/N=(vnpnts, 16) MiniLb2D
	
	//Serial
	MiniLb2D[][%Serial]=Num2str(Serial[p])
	
	//wvName
	MiniLb2D[][%wvName]=wvName[p]
	
	//XLock
	MiniLb2D[][%XLock]=Num2str(XLock[p])
	
	//ALocked
	MiniLb2D[][%ALocked]=Num2str(ALocked[p])
	
	//InitialX
	MiniLb2D[][%InitialX]=Num2str(InitialX[p])
	
	//Isolate
	MiniLb2D[][%Isolate]=Num2str(Isolate[p])
	
	//IEI
	MiniLb2D[][%IEI]=Num2str(IEI[p])
	
	//Base
	MiniLb2D[][%Base]=Num2str(Base[p])
	
	//Peak
	MiniLb2D[][%Peak]=Num2str(Peak[p])
	
	//AreaUC
	MiniLb2D[][%AreaUC]=Num2str(AreaUC[p])
	
	//Decay
	MiniLb2D[][%Decay]=Num2str(Decay[p])
	
	//Rise
	MiniLb2D[][%Rise]=Num2str(Rise[p])
	
	//RecNum
	MiniLb2D[][%RecNum]=RecNum[p]
	
	//Sampling
	MiniLb2D[][%Sampling]=Sampling[p]
	
	//PCurrent
	MiniLb2D[][%PCurrent]=Num2str(PCurrent[p])
	
	//Error
	MiniLb2D[][%Error]=Num2str(Error[p])
end

Function t_Update_MiniLb2D_Select()
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	Variable point = EventSerial - 1
	
	t_Update_MiniLb2D()
	
	If(point <8)
		ListBox Lb0, win=MiniAnaTable, row=-1, selRow= point
	else
		ListBox Lb0, win=MiniAnaTable, row=(point - 9), selRow= point
	endif
end

////////////////////////////////////////
//ParentGraph
Function t_MiniAnaParentGraph()
	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	Display/N=MiniAnaParentGraph /W=(222.75,40.25,477.75,248)/L=MA_LabelAxis0 MA_LabelingWave0
	AppendToGraph/L=MA_LabelAxis1 MA_LabelingWave1
	AppendToGraph Mini_SampleWave
	SetDataFolder fldrSav0
	ModifyGraph margin(left)=43,margin(bottom)=66,margin(top)=57,margin(right)=14,width=198.425
	ModifyGraph height=85.0394
	ModifyGraph mode(MA_LabelingWave0)=3,mode(MA_LabelingWave1)=3
	ModifyGraph marker(MA_LabelingWave0)=10,marker(MA_LabelingWave1)=10
	ModifyGraph rgb(MA_LabelingWave1)=(0,0,65280)
	ModifyGraph msize(MA_LabelingWave0)=2,msize(MA_LabelingWave1)=2
	ModifyGraph noLabel(MA_LabelAxis0)=2,noLabel(MA_LabelAxis1)=2
	ModifyGraph axThick(MA_LabelAxis0)=0,axThick(MA_LabelAxis1)=0
	ModifyGraph lblPos(left)=39
	ModifyGraph freePos(MA_LabelAxis0)=0
	ModifyGraph freePos(MA_LabelAxis1)=0
	ModifyGraph axisEnab(MA_LabelAxis0)={0.9,0.95}
	ModifyGraph axisEnab(MA_LabelAxis1)={0.95,1}
	ModifyGraph axisEnab(left)={0,0.9}
	SetDrawLayer UserFront
	SetDrawEnv fillpat= 0
	DrawRect 0,0,1,1
	DefineGuide UGH0={FB,-30}
	NewPanel/W=(0,0.068,1,0.669)/FG=(,FT,,PT)/HOST=# 
	Button BtMiniParentGraphRect,pos={8,9},size={50,20},proc=t_ParentRect,title="Rect"
	RenameWindow #,P0
	SetActiveSubwindow ##
	NewPanel/W=(0,0.4,1,1)/FG=(,UGH0,,)/HOST=# 
	RenameWindow #,P1
	SetActiveSubwindow ##
end

Function t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)
	Variable V_max_XD, V_min_XD, V_max_YD, V_min_YD
	Variable V_max_XP, V_min_XP, V_max_YP, V_min_YP
	GetAxis/W=MiniAnaParentGraph/Q bottom
	V_max_XP = V_max
	V_min_XP = V_min
	GetAxis/W=MiniAnaParentGraph/Q left
	V_max_YP = V_max
	V_min_YP = V_min
	Variable X0, X1, Y0, Y1
	X0 = (V_min_XD - V_min_XP)/(V_max_XP - V_min_XP)
	X1 = (V_max_XD - V_min_XP)/(V_max_XP - V_min_XP)
	Y0 = (V_max_YD - V_max_YP)/(V_min_YP - V_max_YP)
	Y1 = (V_min_YD - V_max_YP)/(V_min_YP - V_max_YP)
	DrawAction/W=MiniAnaParentGraph delete
	SetDrawEnv/W=MiniAnaParentGraph fillpat= 0
	DrawRect/W=MiniAnaParentGraph X0, Y0, X1, Y1
end

Function t_ParentRect(ctrlName) : ButtonControl
	String ctrlName
	Variable V_max_XD, V_min_XD, V_max_YD, V_min_YD
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	V_max_XD = V_max
	V_min_XD = V_min
	GetAxis/W=MiniAnaDaughterGraph/Q left
	V_max_YD = V_max
	V_min_YD = V_min
	t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)
End

Function t_MA_ShowT0(ctrlName) : ButtonControl
	String ctrlName
	MoveSubwindow/W=MiniAnaTable#T0 fguide = (FL, UGH0, FR, FB)
	ListBox Lb0 disable=1, win=MiniAnaTable
End

Function t_MA_ListBox(ctrlName) : ButtonControl
	String ctrlName
	MoveSubwindow/w=MiniAnaTable#T0 fguide = (FR, FB, FR, FB)
	ListBox Lb0 disable=0, win=MiniAnaTable
End


////////////////////////////////////////////////////////////////////
//Daughter
Function t_MiniAnaDaughterGraph()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	Display/N=MiniAnaDaughterGraph /W=(320.25,281.75,873,597.5)/L=MA_LabelAxis0 MA_LabelingWave0
	//keyboard hook function
	String t = "SetWindowExt kwTopWin"
	Execute t
	SetWindow kwTopWin, hook = t_HookMiniAnaDaughter, hookevents=0
	//end keyboard hook function
	AppendToGraph/L=MA_LabelAxis1 MA_LabelingWave1
	AppendToGraph Mini_SampleWave
	SetDataFolder fldrSav0
	ModifyGraph margin(left)=57,margin(bottom)=61,margin(top)=85,margin(right)=14,width=481.89
	ModifyGraph height=170.079
	ModifyGraph mode(MA_LabelingWave0)=3,mode(MA_LabelingWave1)=3
	ModifyGraph marker(MA_LabelingWave0)=10,marker(MA_LabelingWave1)=10
	ModifyGraph rgb(MA_LabelingWave1)=(0,0,65280)
	ModifyGraph msize(MA_LabelingWave0)=2,msize(MA_LabelingWave1)=2
	ModifyGraph noLabel(MA_LabelAxis0)=2,noLabel(MA_LabelAxis1)=2
	ModifyGraph lblMargin(bottom)=49
	ModifyGraph axThick(MA_LabelAxis0)=0,axThick(MA_LabelAxis1)=0
	ModifyGraph lblPos(left)=53
	ModifyGraph lblLatPos(bottom)=284
	ModifyGraph freePos(MA_LabelAxis0)=0
	ModifyGraph freePos(MA_LabelAxis1)=0
	ModifyGraph axisEnab(MA_LabelAxis0)={0.9,0.95}
	ModifyGraph axisEnab(MA_LabelAxis1)={0.95,1}
	ModifyGraph axisEnab(left)={0,0.9}
	Label bottom "\\u#2s"
	SetDrawLayer UserFront
	DefineGuide UGV0={PR,0.644737,GR},UGH0={FB,-93.75},UGV1={FL,11.25}
	NewPanel/W=(0,0.042,1,0.236)/FG=(,FT,,PT)/HOST=# 
	SetDrawLayer UserBack
	TitleBox TitleRecNumDaughter,pos={13,10},size={83,20}
	TitleBox TitleRecNumDaughter,variable= root:Packages:MiniAna:ExpRecNum
	TitleBox TitleWaveName,pos={106,10},size={37,20}
	TitleBox TitleWaveName,variable= root:Packages:MiniAna:DisplayingWaveMini
	TitleBox TitleDaughterEventNum,pos={180,10},size={60,20}
	TitleBox TitleDaughterEventNum,variable= root:Packages:MiniAna:MiniAnaEventNum
	Button BtDeleteDaughterP0,pos={25,45},size={50,20},proc=t_MiniEventDelete,title="Delete"
	Button BtDaughterIsolateAll,pos={81,34},size={50,20},proc=t_MiniIsoAdAll,title="IsoAdAll"
	Button BtDaughterComplexAll,pos={80,60},size={50,20},proc=t_MiniCoAdAll,title="CoAdAll"
	Button BtIsolateTag,pos={153,48},size={50,20},proc=t_MiniIsolateTag,title="IsoTag"
	Button BtDaughterIsolateModifyAll,pos={222,36},size={50,20},proc=t_MiniIsoMdAll,title="IsoMdAll"
	Button BtDaughterComplexModifyAll,pos={223,58},size={50,20},proc=t_MiniCoMdAll,title="CoMdAll"
	Button MiniDaughterPreviousEvent,pos={9,85},size={50,20},proc=t_BtEventPreNext,title="Previous"
	Button MiniDaughterNextEvent,pos={198,84},size={50,20},proc=t_BtEventPreNext,title="Next"
	Button BtHookOnOFFMiniDaughter,pos={496,24},size={75,20},proc=t_HookOnOff_MiniAnaDaughter,title="HookOnOFF"
	SetVariable SetAnaPeak,pos={289,29},size={125,16},title="Peak"
	SetVariable SetAnaPeak,limits={0,inf,0},value= root:Packages:MiniAna:MiniDispPeak,noedit= 1
	SetVariable SetAnaArea,pos={290,48},size={125,16},title="Area"
	SetVariable SetAnaArea,limits={0,inf,0},value= root:Packages:MiniAna:MiniDispArea,noedit= 1
	SetVariable SetAnaRise,pos={291,67},size={125,16},title="Rise"
	SetVariable SetAnaRise,limits={0,inf,0},value= root:Packages:MiniAna:MiniDispRise,noedit= 1
	SetVariable SetAnaDecay,pos={290,86},size={125,16},title="Decay"
	SetVariable SetAnaDecay,limits={0,inf,0},value= root:Packages:MiniAna:MiniDispDecay,noedit= 1
	Button BtMiniRiseNaN,pos={422,63},size={30,20},proc=t_MiniRiseNaN,title="NaN"
	Button BtMiniDecayNaN,pos={422,84},size={30,20},proc=t_MiniDecayNaN,title="NaN"
	Button BtEraseCursorsMiniDaughter,pos={495,50},size={75,20},proc=t_EraseCursorsMiniAnaDaughter,title="EraseCursors"
	ValDisplay valdisp0,pos={426,13},size={20,20},bodyWidth=20,frame=5
	ValDisplay valdisp0,limits={0,1,0},barmisc={0,0},mode= 2,zeroColor= (0,65280,0)
	ValDisplay valdisp0,value= #"root:Packages:MiniAna:gvError"
	Button BtNaNLabel,pos={632,23},size={75,20},proc=t_MiniLabelWNaN,title="LabelW=NaN"
	Button BtMiniDaughterCsrC,pos={622,61},size={50,20},proc=t_MiniPlaceCsrC,title="CsrC"
	Button BtMiniDSetScale,pos={678,62},size={50,20},proc=t_MiniDaughterSetScale,title="Scale"
	Button BtMiniDaughterPreSweep,pos={621,83},size={50,20},proc=t_MiniD_PreSweep,title="Pre Sw"
	Button BtMiniDaughterNextSweep,pos={676,83},size={50,20},proc=t_MiniD_NextSweep,title="Next Sw"
	SetVariable SetAnaPeak,pos={297,11},size={125,16},title="Peak"
	SetVariable SetAnaPeak,limits={0,inf,0},value= root:Packages:MiniAna:MiniDispPeak,noedit= 1
	SetVariable SetAnaArea,pos={297,29},size={125,16},title="Area"
	SetVariable SetAnaArea,limits={0,inf,0},value= root:Packages:MiniAna:MiniDispArea,noedit= 1
	SetVariable SetAnaRise,pos={297,47},size={125,16},title="Rise"
	SetVariable SetAnaRise,limits={0,inf,0},value= root:Packages:MiniAna:MiniDispRise,noedit= 1
	SetVariable SetAnaDecay,pos={297,65},size={125,16},title="Decay"
	SetVariable SetAnaDecay,limits={0,inf,0},value= root:Packages:MiniAna:MiniDispDecay,noedit= 1
	Button BtMiniRiseNaN,pos={423,42},size={30,20},proc=t_MiniRiseNaN,title="NaN"
	Button BtMiniDecayNaN,pos={423,63},size={30,20},proc=t_MiniDecayNaN,title="NaN"
	RenameWindow #,P0
	SetActiveSubwindow ##
	NewPanel/W=(0.2,0.885,1,0.8)/FG=(FL,,,FB)/HOST=# 
	Slider Slider_MiniAnaDaughterGraph,pos={106,2},size={527,43},proc=t_MiniDaughterSliderProc
	Slider Slider_MiniAnaDaughterGraph,fSize=8
	Slider Slider_MiniAnaDaughterGraph,limits={-100,100,0},value= 0,side= 2,vert= 0,ticks= 10
	Button BtLL_MADaughterP1,pos={10,21},size={20,20},proc=t_Arrow_MA_DaughterGraph,title="<<"
	Button BtL_MADaughterP1,pos={30,21},size={20,20},proc=t_Arrow_MA_DaughterGraph,title="<"
	Button BtR_MADaughterP1,pos={685,21},size={20,20},proc=t_Arrow_MA_DaughterGraph,title=">"
	Button BtRR_MADaughterP1,pos={707,21},size={20,20},proc=t_Arrow_MA_DaughterGraph,title=">>"
	SetVariable SetVarMiniK,pos={11,5},size={61,16}
	SetVariable SetVarMiniK,limits={1,10,1},value= root:Packages:MiniAna:MiniK
	RenameWindow #,P1
	SetActiveSubwindow ##
end

Function t_HookMiniAnaDaughter(infoStr)
	String infoStr
	String event
	String key
	String prev
	Variable state
	Variable AX, RX, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	
	event =StringByKey("Event", infoStr)
	prev = StringByKey("PREV", infoStr)
	
	if(cmpstr(event,"keydown")==0&&cmpstr(prev, "0")==0)
		key = StringByKey("KEY",infoStr)
		strswitch(key)
			case "65":// A
				state =GetKeyState(0)
				If(state & 4)// shift key pressed
					t_MiniHook("Complex add")
				else
					t_MiniHook("Isolate add")
				endif
				break
			case "77":// M (83 == s)
				state =GetKeyState(0)
				if(state & 4)// shift key pressed
					t_MiniHook("Complex mod")
				else
					t_MiniHook("Isolate mod")
				endif
				break
			case "68":// D
				t_MiniHook("Delete")
				break
			case "67":// C
				t_MiniLabelWNaN("")
				break
			case "69":// E
				t_EraseCursorsMiniAnaDaughter("")
				break
			case "16":// shift
				break
			case "78":// N
				t_BtEventPreNext("MiniDaughterNextEvent")
			default:
//				Print key
				break
		endswitch
	endif
	
	if(cmpstr(event,"mousedown")==0)
		//Parent Rect
		GetAxis/W=MiniAnaDaughterGraph/Q bottom
		AX = V_min
		RX = V_max - V_min
		GetAxis/W=MiniAnaDaughterGraph/Q bottom
		V_max_XD = V_max
		V_min_XD = V_min
		GetAxis/W=MiniAnaDaughterGraph/Q left
		V_max_YD = V_max
		V_min_YD = V_min
		t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)
	endif

	return 0
end

Function t_HookOnOff_MiniAnaDaughter(ctrlName) : ButtonControl
	String ctrlName
	Variable keys = 0
	String t = ""
	
	keys = GetKeyState(0)
	
	If(keys & 4 ) // If shift key is pressed
		t = "SetWindowExt/U kwTopWin" // Hook Off
		Execute t
		Print "Hook Off"		
	else
		t = "SetWindowExt kwTopWin" // Hook On
		Execute t
		Print "Hook On"
	endif
End

Function t_EraseCursorsMiniAnaDaughter(ctrlName) : ButtonControl
	String ctrlName
	
	Cursor/K/W=MiniAnaDaughterGraph A
	Cursor/K/W=MiniAnaDaughterGraph B
	Cursor/K/W=MiniAnaDaughterGraph C
	Cursor/K/W=MiniAnaDaughterGraph D
end


Function t_MiniDaughterSliderProc(ctrlName, sliderValue, event) : SliderControl
	String ctrlName
	Variable sliderValue
       Variable event // 4: mouse clicked or released, 9: mouse moved
	Variable V_max_XD, V_min_XD, V_max_YD, V_min_YD
	Variable AX
	Variable RX
	NVAR MiniK = root:Packages:MiniAna:MiniK
	If(event == 9)
		If(sliderValue != 0)
			If(sliderValue > 0)
				Variable s = 0
				Variable f = 1
				GetAxis/W=MiniAnaDaughterGraph/Q bottom
				AX = V_min
				RX = V_max - V_min
				s = AX + RX*MiniK/250
				f = AX + RX + RX*MiniK/250
				SetAxis/W=MiniAnaDaughterGraph bottom s, f

				GetAxis/W=MiniAnaDaughterGraph/Q bottom
				V_max_XD = V_max
				V_min_XD = V_min
				GetAxis/W=MiniAnaDaughterGraph/Q left
				V_max_YD = V_max
				V_min_YD = V_min
				t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)
			else
				s = 0
				f = 1
				GetAxis/W=MiniAnaDaughterGraph/Q bottom
				AX = V_min
				RX = V_max - V_min
				s = AX - RX*MiniK/250
				f = AX + RX - RX*MiniK/250
				SetAxis/W=MiniAnaDaughterGraph bottom s, f
				
				GetAxis/W=MiniAnaDaughterGraph/Q bottom
				V_max_XD = V_max
				V_min_XD = V_min
				GetAxis/W=MiniAnaDaughterGraph/Q left
				V_max_YD = V_max
				V_min_YD = V_min
				t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)
			endIf
		endIf
	endIf
	
	If(event == 4)
		Slider Slider_MiniAnaDaughterGraph value=0, win=MiniAnaDaughterGraph#P1
	endIf
	
	return 0
End

Function t_Arrow_MA_DaughterGraph(ctrlName) : ButtonControl
	String ctrlName
	Variable AX, RX, s, f, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	NVAR MiniK = root:Packages:MiniAna:MiniK
	String sdw = StringFromList(0, Wavelist("!*Labeling*", ";", "WIN:MiniAnaDaughterGraph"))
	Wave dw = $sdw
	StrSwitch(ctrlName)
		case "BtLL_MADaughterP1":
			GetAxis/W=MiniAnaDaughterGraph/Q bottom
			AX = V_min
			RX = V_max - V_min
			s = leftx(dw)
			f = leftx(dw) + RX
			SetAxis/W=MiniAnaDaughterGraph bottom s, f
			GetAxis/W=MiniAnaDaughterGraph/Q bottom
			V_max_XD = V_max
			V_min_XD = V_min
			GetAxis/W=MiniAnaDaughterGraph/Q left
			V_max_YD = V_max
			V_min_YD = V_min
			t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)
			break
		case "BtL_MADaughterP1":
			GetAxis/W=MiniAnaDaughterGraph/Q bottom
			AX = V_min
			RX = V_max - V_min
			s = AX - RX*MiniK/5
			f = AX + RX - RX*MiniK/5
			SetAxis/W=MiniAnaDaughterGraph bottom s, f
			GetAxis/W=MiniAnaDaughterGraph/Q bottom
			V_max_XD = V_max
			V_min_XD = V_min
			GetAxis/W=MiniAnaDaughterGraph/Q left
			V_max_YD = V_max
			V_min_YD = V_min
			t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)
			break
		case "BtRR_MADaughterP1":
			GetAxis/W=MiniAnaDaughterGraph/Q bottom
			AX = V_min
			RX = V_max - V_min
			s = rightx(dw) - RX
			f = rightx(dw)
			SetAxis/W=MiniAnaDaughterGraph bottom s, f
			GetAxis/W=MiniAnaDaughterGraph/Q bottom
			V_max_XD = V_max
			V_min_XD = V_min
			GetAxis/W=MiniAnaDaughterGraph/Q left
			V_max_YD = V_max
			V_min_YD = V_min
			t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)
			break
		case "BtR_MADaughterP1":
			GetAxis/W=MiniAnaDaughterGraph/Q bottom
			AX = V_min
			RX = V_max - V_min
			s = AX + RX*MiniK/5
			f = AX + RX + RX*MiniK/5
			SetAxis/W=MiniAnaDaughterGraph bottom s, f
			GetAxis/W=MiniAnaDaughterGraph/Q bottom
			V_max_XD = V_max
			V_min_XD = V_min
			GetAxis/W=MiniAnaDaughterGraph/Q left
			V_max_YD = V_max
			V_min_YD = V_min
			t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)
			break
		default:
			break
	endSwitch
End

Function t_MiniEventDelete(ctrlName) : ButtonControl
	String ctrlName
	SVAR ExpRecNum = root:Packages:MiniAna:ExpRecNum
	SVAR SamplingHz = root:Packages:MiniAna:SamplingHz
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR SetMiniArtifactX = root:Packages:MiniAna:SetMiniArtifactX
	NVAR MiniDispPeak = root:Packages:MiniAna:MiniDispPeak
	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	NVAR SetMiniPCurrent = root:Packages:MiniAna:SetMiniPCurrent
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	NVAR gvError = root:Packages:MiniAna:gvError
	Wave dw = $tWaveMini
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	Wave luw0 = $(tWaveMini + "_Label0")
	Wave luw1 = $(tWaveMini + "_Label1")
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave IEI = root:Packages:MiniAna:IEI
	Wave Base = root:Packages:MiniAna:Base
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUC = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Wave/T Sampling = root:Packages:MiniAna:Sampling
	Wave PCurrent = root:Packages:MiniAna:PCurrent
	Wave Error = root:Packages:MiniAna:Error
	Wave basefit = $(tWaveMini + "_basefit")
	Variable i = 0
	Variable AX, RX, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	String SFL

	//T0 Wavelist
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0

	Variable PeakXLock = XLock[EventSerial - 1]

	//
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLock
	lw0[pcsr(B)] = NaN
	lw1[pcsr(B)] = NaN
	luw0 = lw0
	luw1 = lw1
	
	Variable DeletingPoint = EventSerial - 1
	Variable SerialN = numpnts(Serial)
	//IEI and LabelingWave
	ControlInfo/W=MiniAnaMain CheckInterEventInterval_tab3
	If(V_value)
		If(DeletingPoint !=0)
			If((DeletingPoint+1) != SerialN)
				If(StringMatch(wvName[DeletingPoint-1], wvName[DeletingPoint+1]))
					If((XLock[DeletingPoint+1]-XLock[DeletingPoint-1])>0.9*IsoCriteria)
						Print "1"
						Cursor/W=MiniAnaDaughterGraph D $tWaveMini XLock[DeletingPoint-1]
//						lw1[pcsr(D)] = 1
//						luw1[pcsr(D)] = 1
//						Isolate[DeletingPoint-1] = 1
						Cursor/W=MiniAnaDaughterGraph F $tWaveMini XLock[DeletingPoint+1]
						lw1[pcsr(F)] = 1
						luw1[pcsr(F)] = 1
						Isolate[DeletingPoint+1] = 1
					else
						If((XLock[DeletingPoint+1]-XLock[DeletingPoint-1])>0.1*IsoCriteria)
							Print "2"
							Cursor/W=MiniAnaDaughterGraph F $tWaveMini XLock[DeletingPoint+1]
							lw1[pcsr(F)] = 1
							luw1[pcsr(F)] = 1
							Isolate[DeletingPoint+1] = 1
						endIf
					endIf			
				else
					DoAlert 0, "Certify Previous Wave."
					If((XLock[DeletingPoint+2]-XLock[DeletingPoint+1])>0.9*IsoCriteria)
						Cursor/W=MiniAnaDaughterGraph F $tWaveMini XLock[DeletingPoint+1]
						lw1[pcsr(F)] = 1
						luw1[pcsr(F)] = 1
						Isolate[DeletingPoint+1] = 1
					endIf
				endIf
			else	
				If((XLock[DeletingPoint-1]-XLock[DeletingPoint-2])>0.1*IsoCriteria)
					Print "3"
					Cursor/W=MiniAnaDaughterGraph D $tWaveMini XLock[DeletingPoint-1]
					lw1[pcsr(D)] = 1
					luw1[pcsr(D)] = 1
					Isolate[DeletingPoint-1] = 1
				endIf
			endIf
		else
			If((XLock[DeletingPoint+2]-XLock[DeletingPoint+1])>0.9*IsoCriteria)
				Print "4"
				Cursor/W=MiniAnaDaughterGraph F $tWaveMini XLock[DeletingPoint+1]
				lw1[pcsr(F)] = 1
				luw1[pcsr(F)] = 1
				Isolate[DeletingPoint+1] = 1
			endIf
		endIf
	endIf
		
	//
	i = 0
	do
		SFL = StringFromList(i, T0WL)
		If(Strlen(SFL)<1)
			break
		endIf
		
		Deletepoints DeletingPoint, 1, $("root:Packages:MiniAna:" + SFL)
		i += 1
	while(1)

	Serial[p,] = x + 1
	
	Variable InsertingPoint = DeletingPoint
	EventSerial = InsertingPoint + 1
	Variable point = InsertingPoint
	
	//Event graph set axis
//	EventXLock = XLock[point]
//	If(StringMatch(EventWaveName,wvName[point]) == 1)
//		EventWaveName = wvName[point]
//	else
//		RemoveFromGraph/W=MiniAnaEventGraph $EventWaveName
//		AppendToGraph/W=MiniAnaEventGraph $wvName[point]
//		EventWaveName = wvName[point]
//	endIf
//	SetAxis/W = MiniAnaEventGraph bottom, (EventXLock-0.3*IsoCriteria), (EventXLock+1.1*IsoCriteria)
	
	//Event graph cursor
	Cursor/W=MiniAnaEventGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaEventGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaEventGraph C $wvName[point] xcsr(C)
	
	//Daughter graph set axis
//	GetAxis/W = MiniAnaDaughterGraph bottom
//	Variable graphwidth = V_max - V_min
//	SetAxis/W = MiniAnaDaughterGraph bottom, (XLock[point] - 0.2*graphwidth), (XLock[point] + 0.8*graphwidth)

	//Daughter graph set axis
	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaDaughterGraph C $wvName[point] XLock[point]+ 10e-3
//	DetectAreaDecayRange

	//Parent Rect
//	GetAxis/W=MiniAnaDaughterGraph/Q bottom
//	AX = V_min
//	RX = V_max - V_min
//	GetAxis/W=MiniAnaDaughterGraph/Q bottom
//	V_max_XD = V_max
//	V_min_XD = V_min
//	GetAxis/W=MiniAnaDaughterGraph/Q left
//	V_max_YD = V_max
//	V_min_YD = V_min
//	t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)

	//Table event selection
//	ModifyTable/w=MiniAnaTable#T0 selection=(point,0,point,100,0,0)
	
	//Update display
	MiniDispPeak = NaN
	MiniDispArea = NaN
	MiniDispRise = NaN
	MiniDispDecay = NaN
	
	t_MiniEventLine("")
	
	t_Update_MiniLb2D_Select()
End

Function t_Delete_Mini() //Marquee Control
	SVAR ExpRecNum = root:Packages:MiniAna:ExpRecNum
	SVAR SamplingHz = root:Packages:MiniAna:SamplingHz
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR SetMiniArtifactX = root:Packages:MiniAna:SetMiniArtifactX
	NVAR MiniDispPeak = root:Packages:MiniAna:MiniDispPeak
	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	NVAR SetMiniPCurrent = root:Packages:MiniAna:SetMiniPCurrent
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	NVAR gvError = root:Packages:MiniAna:gvError
	Wave dw = $tWaveMini
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	Wave luw0 = $(tWaveMini + "_Label0")
	Wave luw1 = $(tWaveMini + "_Label1")
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave IEI = root:Packages:MiniAna:IEI
	Wave Base = root:Packages:MiniAna:Base
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUC = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Wave/T Sampling = root:Packages:MiniAna:Sampling
	Wave PCurrent = root:Packages:MiniAna:PCurrent
	Wave Error = root:Packages:MiniAna:Error
	Wave basefit = $(tWaveMini + "_basefit")
	Variable i = 0
	Variable AX, RX, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	String SFL

	//T0 Wavelist
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0

	Variable PeakXLock = XLock[EventSerial - 1]

	//
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLock
	lw0[pcsr(B)] = NaN
	lw1[pcsr(B)] = NaN
	luw0 = lw0
	luw1 = lw1
	
	Variable DeletingPoint = EventSerial - 1
	Print DeletingPoint
	Variable SerialN = numpnts(Serial)
	Print SerialN
	//IEI  LabelingWave
	ControlInfo/W=MiniAnaMain CheckInterEventInterval_tab3
	If(V_value)
		If(DeletingPoint !=0)
			If((DeletingPoint+1) != SerialN)
				If(StringMatch(wvName[DeletingPoint-1], wvName[DeletingPoint+1]))
					If((XLock[DeletingPoint+1]-XLock[DeletingPoint-1])>0.9*IsoCriteria)
						Print "1"
						Cursor/W=MiniAnaDaughterGraph D $tWaveMini XLock[DeletingPoint-1]
//						lw1[pcsr(D)] = 1
//						luw1[pcsr(D)] = 1
//						Isolate[DeletingPoint-1] = 1
						Cursor/W=MiniAnaDaughterGraph F $tWaveMini XLock[DeletingPoint+1]
						lw1[pcsr(F)] = 1
						luw1[pcsr(F)] = 1
						Isolate[DeletingPoint+1] = 1
					else
						If((XLock[DeletingPoint+1]-XLock[DeletingPoint-1])>0.1*IsoCriteria)
							Print "2"
							Cursor/W=MiniAnaDaughterGraph F $tWaveMini XLock[DeletingPoint+1]
							lw1[pcsr(F)] = 1
							luw1[pcsr(F)] = 1
							Isolate[DeletingPoint+1] = 1
						endIf
					endIf			
				else
					DoAlert 0, "Certify Previous Wave."
					If((XLock[DeletingPoint+2]-XLock[DeletingPoint+1])>0.9*IsoCriteria)
						Print "3"
						Cursor/W=MiniAnaDaughterGraph F $tWaveMini XLock[DeletingPoint+1]
						lw1[pcsr(F)] = 1
						luw1[pcsr(F)] = 1
						Isolate[DeletingPoint+1] = 1
					endIf
				endIf
			else	
				If((XLock[DeletingPoint-1]-XLock[DeletingPoint-2])>0.1*IsoCriteria)
					Print "4"
					Cursor/W=MiniAnaDaughterGraph D $tWaveMini XLock[DeletingPoint-1]
					lw1[pcsr(D)] = 1
					luw1[pcsr(D)] = 1
					Isolate[DeletingPoint-1] = 1
				endIf
			endIf
		else
			If((XLock[DeletingPoint+2]-XLock[DeletingPoint+1])>0.9*IsoCriteria)
				Print "5"
				Cursor/W=MiniAnaDaughterGraph F $tWaveMini XLock[DeletingPoint+1]
				lw1[pcsr(F)] = 1
				luw1[pcsr(F)] = 1
				Isolate[DeletingPoint+1] = 1
			endIf
		endIf
	endIf
		
	// 
	i = 0
	do
		SFL = StringFromList(i, T0WL)
		If(Strlen(SFL)<1)
			break
		endIf
		
		Deletepoints DeletingPoint, 1, $("root:Packages:MiniAna:" + SFL)
		i += 1
	while(1)

	Serial[p,] = x + 1
	
	Variable InsertingPoint = DeletingPoint
	EventSerial = InsertingPoint + 1
	Variable point = InsertingPoint
	
	//Event graph set axis
//	EventXLock = XLock[point]
//	If(StringMatch(EventWaveName,wvName[point]) == 1)
//		EventWaveName = wvName[point]
//	else
//		RemoveFromGraph/W=MiniAnaEventGraph $EventWaveName
//		AppendToGraph/W=MiniAnaEventGraph $wvName[point]
//		EventWaveName = wvName[point]
//	endIf
//	SetAxis/W = MiniAnaEventGraph bottom, (EventXLock-0.3*IsoCriteria), (EventXLock+1.1*IsoCriteria)
	
	//Event graph cursor
	Cursor/W=MiniAnaEventGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaEventGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaEventGraph C $wvName[point] xcsr(C)
	
	//Daughter graph set axis
//	GetAxis/W = MiniAnaDaughterGraph bottom
//	Variable graphwidth = V_max - V_min
//	SetAxis/W = MiniAnaDaughterGraph bottom, (XLock[point] - 0.2*graphwidth), (XLock[point] + 0.8*graphwidth)

	//Daughter graph set axis
	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaDaughterGraph C $wvName[point] XLock[point]+10e-3
//	DetectAreaDecayRange

	//Parent graph rect
//	GetAxis/W=MiniAnaDaughterGraph/Q bottom
//	AX = V_min
//	RX = V_max - V_min
//	GetAxis/W=MiniAnaDaughterGraph/Q bottom
//	V_max_XD = V_max
//	V_min_XD = V_min
//	GetAxis/W=MiniAnaDaughterGraph/Q left
//	V_max_YD = V_max
//	V_min_YD = V_min
//	t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)

	//Table event selection
//	ModifyTable/w=MiniAnaTable#T0 selection=(point,0,point,100,0,0)
	
	//Update display
	MiniDispPeak = NaN
	MiniDispArea = NaN
	MiniDispRise = NaN
	MiniDispDecay = NaN
	
	t_MiniEventLine("")
	
	t_Update_MiniLb2D_Select()
End
	
Function t_MiniIsolateTag(ctrlName) : ButtonControl
	String ctrlName
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR SetMiniArtifactX = root:Packages:MiniAna:SetMiniArtifactX
	NVAR SetMiniPCurrent = root:Packages:MiniAna:SetMiniPCurrent
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	NVAR gvError = root:Packages:MiniAna:gvError
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	Wave luw0 = $(tWaveMini + "_Label0")
	Wave luw1 = $(tWaveMini + "_Label1")
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Cursor/W=MiniAnaDaughterGraph E $tWaveMini XLock[EventSerial-1]
	If(Isolate[EventSerial-1])
		lw1[pcsr(E)] = NaN
		luw1[pcsr(E)] = NaN
		Isolate[EventSerial-1] = 0
	else
		lw1[pcsr(E)] = 1
		luw1[pcsr(E)] = 1
		Isolate[EventSerial-1] = 1
	endIf
	
	t_Update_MiniLb2D_Select()	
End

Function t_MiniIsoAdAll(ctrlName) : ButtonControl
	String ctrlName
	SVAR ExpRecNum = root:Packages:MiniAna:ExpRecNum
	SVAR SamplingHz = root:Packages:MiniAna:SamplingHz
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR SetMiniArtifactX = root:Packages:MiniAna:SetMiniArtifactX
	NVAR MiniDispPeak = root:Packages:MiniAna:MiniDispPeak
	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	NVAR SetMiniPCurrent = root:Packages:MiniAna:SetMiniPCurrent
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	NVAR gvError = root:Packages:MiniAna:gvError
	Wave dw = $tWaveMini
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	Wave luw0 = $(tWaveMini + "_Label0")
	Wave luw1 = $(tWaveMini + "_Label1")
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave IEI = root:Packages:MiniAna:IEI
	Wave Base = root:Packages:MiniAna:Base
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUC = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Wave/T Sampling = root:Packages:MiniAna:Sampling
	Wave PCurrent = root:Packages:MiniAna:PCurrent
	Wave Error = root:Packages:MiniAna:Error
	Wave basefit = $(tWaveMini + "_basefit")
	Variable i = 0
	Variable AX, RX, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	String SFL

	//T0 wavelist
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0

	//
	Variable PeakXLoc = xcsr(B)
	
	//
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	lw0[pcsr(B)] = 1
	lw1[pcsr(B)] = 1
	luw0 = lw0
	luw1 = lw1
	
	//
	WaveStats/M=1/Q Serial
	Variable npnts = V_npnts + 1
	i = 0
	do
		SFL = StringFromList(i, T0WL)
		If(Strlen(SFL)<1)
			break
		endIf
		
		Insertpoints npnts, 1, $("root:Packages:MiniAna:" + SFL)
		i += 1
	while(1)
	
	//wvName
	wvName[npnts] = tWaveMini
	
	//wvXLock
	XLock[npnts] = xcsr(B)
	
	//ALocked
	ControlInfo/W=MiniAnaMain CheckALockedX_tab3
	If(V_value)
		ALocked[npnts] = XLock[npnts] - SetMiniArtifactX
	endIf
	
	//InitialX
	InitialX[npnts] = xcsr(A)
	
	//Isolate
	ControlInfo/W=MiniAnaMain CheckIsolateTag_tab3
	If(V_value)
		Isolate[npnts] = 1
	endIf
	
	//Base
	Base[npnts] = Mean(basefit, (InitialX[npnts] - deltax(basefit)), (InitialX[npnts] + deltax(basefit)))
	
	//Peak
	ControlInfo/W=MiniAnaMain CheckPeak_tab3
	If(V_value)
		Peak[npnts] = ABS(basefit(XLock[npnts]) - Base[npnts])
	endIf
	
	//Area
	ControlInfo/W=MiniAnaMain CheckArea_tab3
	If(V_value)
		Variable area_a = (basefit(xcsr(C))-basefit(xcsr(A)))/(xcsr(C)-xcsr(A))
		Variable area_b = 0.5*(basefit(xcsr(A))+basefit(xcsr(C))-(xcsr(A)+xcsr(C))*area_a)
		Wave MiniArea0 = root:Packages:MiniAna:MiniArea0
		Wave MiniArea1 = root:Packages:MiniAna:MiniArea1
		MiniArea0 = area_a*x+area_b
		MiniArea1 = basefit - MiniArea0
		AreaUC[npnts] = Area(MiniArea1, xcsr(A), xcsr(C))
	endIf
	
	//Decay
	ControlInfo/W=MiniAnaMain CheckDecay_tab3
	If(V_value)
		CurveFit/Q/NTHR = 0 exp_XOffset basefit(xcsr(B), xcsr(C))
		Wave W_coef
		If(W_coef[2]>0&&W_coef[2]<0.02)
			Decay[npnts] = W_coef[2]
		else
			Decay[npnts] = NaN
		endIf
	endIf
	
	//Rise
	ControlInfo/W=MiniAnaMain CheckRise_tab3
	If(V_value)
		Variable RTXLock0
		Variable RTXLock1
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.1*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock0 = V_LevelX
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.9*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock1 = V_LevelX
		If((RTXLock1 - RTXLock0)>0)
			Rise[npnts] = RTXLock1 - RTXLock0
		else
			Rise[npnts] = NaN
		endIf
	endIf
	
	//RecNum
	ControlInfo/W=MiniAnaMain CheckExpRecNum_tab3
	If(V_value)
		RecNum[npnts] = ExpRecNum
	endIf
	
	//Sampling
	ControlInfo/W=MiniAnamain CheckSamplingHz_tab3
	If(V_value)
		Sampling[npnts] = SamplingHz
	endIf
	
	//PCurrent
	ControlInfo/W=MiniAnaMain CheckParentCurrent_tab3
	If(V_value)
		PCurrent[npnts] = SetMiniPCurrent
	endIf
	
	//Error
	ControlInfo/W=MiniAnaMain CheckError_tab3
	If(V_value)
		Error[npnts] = 0
	endIf
	
	//Sorting
	fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String ForSort1 = Wavelist("*", ",", "WIN:MiniAnaTable#T0")
	String ForSort2 = ForSort1[0, (Strlen(T0WL)-1)]
	String t = "Sort/A {wvName, XLock, Serial}," + ForSort2
	Execute t
	SetDataFolder fldrsav0

	//Serial and IEI
	FindLevel /Q Serial, 0
	Variable InsertingPoint = V_LevelX
	Serial[p,] = x + 1
	//IEI and LabelingWaves
	ControlInfo/W=MiniAnaMain CheckInterEventInterval_tab3
	If(V_value)
		If(InsertingPoint !=0)
			If(StringMatch(wvName[InsertingPoint], wvName[InsertingPoint-1]))
				IEI[InsertingPoint] = XLock[InsertingPoint] - XLock[InsertingPoint - 1]
				If((XLock[InsertingPoint]-XLock[InsertingPoint-1])<0.9*IsoCriteria)
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[InsertingPoint-1]
					lw1[pcsr(D)] = NaN
					luw1[pcsr(D)] = NaN
					Isolate[InsertingPoint-1] = 0
				endIf
				If(numpnts(Serial) != InsertingPoint+1)
					IEI[InsertingPoint+1] = XLock[InsertingPoint+1] - XLock[InsertingPoint]
				endIf
			else
				Print "2"
				IEI[InsertingPoint] = NaN
			endIf
		else
			IEI[InsertingPoint] = NaN
			If(numpnts(Serial)>1)
				IEI[InsertingPoint+1] = XLock[InsertingPoint+1] - XLock[InsertingPoint]
			endIf
		endIf
	endIf
	
	EventSerial = InsertingPoint + 1
	Variable point = InsertingPoint
	
	//Event graph set axis
	EventXLock = XLock[point]
	If(StringMatch(EventWaveName,wvName[point]) == 1)
		EventWaveName = wvName[point]
	else
		RemoveFromGraph/W=MiniAnaEventGraph $EventWaveName
		AppendToGraph/W=MiniAnaEventGraph $wvName[point]
		EventWaveName = wvName[point]
	endIf
	SetAxis/W = MiniAnaEventGraph bottom, (EventXLock-0.3*IsoCriteria), (EventXLock+1.1*IsoCriteria)
	
	//Event graph cursor
	Cursor/W=MiniAnaEventGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaEventGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaEventGraph C $wvName[point] xcsr(C)
	
	//Daughter
//	GetAxis/W = MiniAnaDaughterGraph bottom
//	Variable graphwidth = V_max - V_min
//	SetAxis/W = MiniAnaDaughterGraph bottom, (XLock[point] - 0.2*graphwidth), (XLock[point] + 0.8*graphwidth)

	//Daughter
//	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
//	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
//	Cursor/W=MiniAnaDaughterGraph C $wvName[point] XLock[point]+DetectAreaDecayRange

	//Parent graph Rect
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	AX = V_min
	RX = V_max - V_min
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	V_max_XD = V_max
	V_min_XD = V_min
	GetAxis/W=MiniAnaDaughterGraph/Q left
	V_max_YD = V_max
	V_min_YD = V_min
	t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)

	//Table event selection
	ModifyTable/w=MiniAnaTable#T0 selection=(point,0,point,100,0,0)
	
	//Update display
	MiniDispPeak = Peak[point]
	MiniDispArea = AreaUC[point]
	MiniDispRise = Rise[point]
	MiniDispDecay = Decay[point]
	gvError = Error[point]
	
	t_MiniEventLine("")
	
	t_Update_MiniLb2D_Select()
End

Function t_IsoAddAll_Mini() //Marquee Control
	SVAR ExpRecNum = root:Packages:MiniAna:ExpRecNum
	SVAR SamplingHz = root:Packages:MiniAna:SamplingHz
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR SetMiniArtifactX = root:Packages:MiniAna:SetMiniArtifactX
	NVAR MiniDispPeak = root:Packages:MiniAna:MiniDispPeak
	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	NVAR SetMiniPCurrent = root:Packages:MiniAna:SetMiniPCurrent
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	NVAR gvError = root:Packages:MiniAna:gvError
	Wave dw = $tWaveMini
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	Wave luw0 = $(tWaveMini + "_Label0")
	Wave luw1 = $(tWaveMini + "_Label1")
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave IEI = root:Packages:MiniAna:IEI
	Wave Base = root:Packages:MiniAna:Base
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUC = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Wave/T Sampling = root:Packages:MiniAna:Sampling
	Wave PCurrent = root:Packages:MiniAna:PCurrent
	Wave Error = root:Packages:MiniAna:Error
	Wave basefit = $(tWaveMini + "_basefit")
	Variable i = 0
	Variable AX, RX, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	String SFL

	//Place Cursors
	String tMinitWin = WinName(0,1)
	GetMarquee bottom
	Cursor/W=$tMinitWin A $tWaveMini V_left
	Cursor/W=$tMinitWin C $tWaveMini V_right
	WaveStats/M=1/Q/R=(V_left, V_right) $tWaveMini
	ControlInfo/W=MiniAnaMain PopupPeakDetect_tab2
	Switch (V_value)
		case 1:
			Cursor/W=$tMinitWin B $tWaveMini V_minLoc
			break;
		case 2:
			Cursor/W=$tMinitWin B $tWaveMini V_maxLoc
			break;
		case 3:
			If(ABS(V_min)>ABS(V_max))
				Cursor/W=$tMinitWin B $tWaveMini V_minLoc
			else
				Cursor/W=$tMinitWin B $tWaveMini V_maxLoc
			endif
			break;
		default:
			break;
	endSwitch
				
	//
	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0

	//
	Variable PeakXLoc = xcsr(B)
	
	//
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	lw0[pcsr(B)] = 1
	lw1[pcsr(B)] = 1
	luw0 = lw0
	luw1 = lw1
	
	//
	WaveStats/M=1/Q Serial
	Variable npnts = V_npnts + 1
	i = 0
	do
		SFL = StringFromList(i, T0WL)
		If(Strlen(SFL)<1)
			break
		endIf
		
		Insertpoints npnts, 1, $("root:Packages:MiniAna:" + SFL)
		i += 1
	while(1)
	
	//wvName
	wvName[npnts] = tWaveMini
	
	//wvXLock
	XLock[npnts] = xcsr(B)
	
	//ALocked
	ControlInfo/W=MiniAnaMain CheckALockedX_tab3
	If(V_value)
		ALocked[npnts] = XLock[npnts] - SetMiniArtifactX
	endIf
	
	//InitialX
	InitialX[npnts] = xcsr(A)
	
	//Isolate
	ControlInfo/W=MiniAnaMain CheckIsolateTag_tab3
	If(V_value)
		Isolate[npnts] = 1
	endIf
	
	//Base
	Base[npnts] = Mean(basefit, (InitialX[npnts] - deltax(basefit)), (InitialX[npnts] + deltax(basefit)))
	
	//Peak
	ControlInfo/W=MiniAnaMain CheckPeak_tab3
	If(V_value)
		Peak[npnts] = ABS(basefit(XLock[npnts]) - Base[npnts])
	endIf
	
	//Area
	ControlInfo/W=MiniAnaMain CheckArea_tab3
	If(V_value)
		Variable area_a = (basefit(xcsr(C))-basefit(xcsr(A)))/(xcsr(C)-xcsr(A))
		Variable area_b = 0.5*(basefit(xcsr(A))+basefit(xcsr(C))-(xcsr(A)+xcsr(C))*area_a)
		Wave MiniArea0 = root:Packages:MiniAna:MiniArea0
		Wave MiniArea1 = root:Packages:MiniAna:MiniArea1
		MiniArea0 = area_a*x+area_b
		MiniArea1 = basefit - MiniArea0
		AreaUC[npnts] = Area(MiniArea1, xcsr(A), xcsr(C))
	endIf
	
	//Decay
	ControlInfo/W=MiniAnaMain CheckDecay_tab3
	If(V_value)
		CurveFit/Q/NTHR = 0 exp_XOffset basefit(xcsr(B), xcsr(C))

		Wave W_coef
		If(W_coef[2]>0&&W_coef[2]<0.02)
			Decay[npnts] = W_coef[2]
		else
			Decay[npnts] = NaN
		endIf

	endIf
	
	//Rise
	ControlInfo/W=MiniAnaMain CheckRise_tab3
	If(V_value)
		Variable RTXLock0
		Variable RTXLock1
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.1*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock0 = V_LevelX
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.9*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock1 = V_LevelX
		If((RTXLock1 - RTXLock0)>0)
			Rise[npnts] = RTXLock1 - RTXLock0
		else
			Rise[npnts] = NaN
		endIf
	endIf
	
	//RecNum
	ControlInfo/W=MiniAnaMain CheckExpRecNum_tab3
	If(V_value)
		RecNum[npnts] = ExpRecNum
	endIf
	
	//Sampling
	ControlInfo/W=MiniAnamain CheckSamplingHz_tab3
	If(V_value)
		Sampling[npnts] = SamplingHz
	endIf
	
	//PCurrent
	ControlInfo/W=MiniAnaMain CheckParentCurrent_tab3
	If(V_value)
		PCurrent[npnts] = SetMiniPCurrent
	endIf
	
	//Error
	ControlInfo/W=MiniAnaMain CheckError_tab3
	If(V_value)
		Error[npnts] = 0
	endIf
	
	//Sorting
	fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String ForSort1 = Wavelist("*", ",", "WIN:MiniAnaTable#T0")
	String ForSort2 = ForSort1[0, (Strlen(T0WL)-1)]
	String t = "Sort/A {wvName, XLock, Serial}," + ForSort2
	Execute t
	SetDataFolder fldrsav0

	//Serial and IEI
	FindLevel /Q Serial, 0
	Variable InsertingPoint = V_LevelX
	Serial[p,] = x + 1
	
	//IEI and LabelingWave
	ControlInfo/W=MiniAnaMain CheckInterEventInterval_tab3
	If(V_value)
		If(InsertingPoint !=0)
			If(StringMatch(wvName[InsertingPoint], wvName[InsertingPoint-1]))
				IEI[InsertingPoint] = XLock[InsertingPoint] - XLock[InsertingPoint - 1]
				If((XLock[InsertingPoint]-XLock[InsertingPoint-1])<0.9*IsoCriteria)
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[InsertingPoint-1]
					lw1[pcsr(D)] = NaN
					luw1[pcsr(D)] = NaN
					Isolate[InsertingPoint-1] = 0
				endIf
				If(numpnts(Serial) != InsertingPoint+1)
					IEI[InsertingPoint+1] = XLock[InsertingPoint+1] - XLock[InsertingPoint]
				endIf
			else
				IEI[InsertingPoint] = NaN
			endIf
		else
			IEI[InsertingPoint] = NaN
			If(numpnts(Serial)>1)
				IEI[InsertingPoint+1] = XLock[InsertingPoint+1] - XLock[InsertingPoint]
			endIf
		endIf
	endIf
	
	EventSerial = InsertingPoint + 1
	Variable point = InsertingPoint
	
	//
	EventXLock = XLock[point]
	If(StringMatch(EventWaveName,wvName[point]) == 1)
		EventWaveName = wvName[point]
	else
		RemoveFromGraph/W=MiniAnaEventGraph $EventWaveName
		AppendToGraph/W=MiniAnaEventGraph $wvName[point]
		EventWaveName = wvName[point]
	endIf
	SetAxis/W = MiniAnaEventGraph bottom, (EventXLock-0.3*IsoCriteria), (EventXLock+1.1*IsoCriteria)
	
	//
	Cursor/W=MiniAnaEventGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaEventGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaEventGraph C $wvName[point] xcsr(C)
	
	//
//	GetAxis/W = MiniAnaDaughterGraph bottom
//	Variable graphwidth = V_max - V_min
//	SetAxis/W = MiniAnaDaughterGraph bottom, (XLock[point] - 0.2*graphwidth), (XLock[point] + 0.8*graphwidth)

	//
//	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
//	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
//	Cursor/W=MiniAnaDaughterGraph C $wvName[point] XLock[point]+DetectAreaDecayRange

	//
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	AX = V_min
	RX = V_max - V_min
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	V_max_XD = V_max
	V_min_XD = V_min
	GetAxis/W=MiniAnaDaughterGraph/Q left
	V_max_YD = V_max
	V_min_YD = V_min
	t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)

	// 
	ModifyTable/w=MiniAnaTable#T0 selection=(point,0,point,100,0,0)
	
	//Update display
	MiniDispPeak = Peak[point]
	MiniDispArea = AreaUC[point]
	MiniDispRise = Rise[point]
	MiniDispDecay = Decay[point]
	gvError = Error[point]
	
	t_MiniEventLine("")
	
	t_Update_MiniLb2D_Select()
End
	

Function t_MiniCoAdAll(ctrlName) : ButtonControl
	String ctrlName
	SVAR ExpRecNum = root:Packages:MiniAna:ExpRecNum
	SVAR SamplingHz = root:Packages:MiniAna:SamplingHz
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR SetMiniArtifactX = root:Packages:MiniAna:SetMiniArtifactX
	NVAR MiniDispPeak = root:Packages:MiniAna:MiniDispPeak
	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	NVAR SetMiniPCurrent = root:Packages:MiniAna:SetMiniPCurrent
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	NVAR gvError = root:Packages:MiniAna:gvError
	Wave dw = $tWaveMini
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	Wave luw0 = $(tWaveMini + "_Label0")
	Wave luw1 = $(tWaveMini + "_Label1")
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave IEI = root:Packages:MiniAna:IEI
	Wave Base = root:Packages:MiniAna:Base
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUC = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Wave/T Sampling = root:Packages:MiniAna:Sampling
	Wave PCurrent = root:Packages:MiniAna:PCurrent
	Wave Error = root:Packages:MiniAna:Error
	Wave basefit = $(tWaveMini + "_basefit")
	Variable i = 0
	Variable AX, RX, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	String SFL

	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0

	Variable PeakXLoc = xcsr(B)
	
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	lw0[pcsr(B)] = 1
	lw1[pcsr(B)] = NaN
	luw0 = lw0
	luw1 = lw1
	
	WaveStats/M=1/Q Serial
	Variable npnts = V_npnts + 1
	i = 0
	do
		SFL = StringFromList(i, T0WL)
		If(Strlen(SFL)<1)
			break
		endIf
		
		Insertpoints npnts, 1, $("root:Packages:MiniAna:" + SFL)
		i += 1
	while(1)
	
	//wvName
	wvName[npnts] = tWaveMini
	
	//wvXLock
	XLock[npnts] = xcsr(B)
	
	//ALocked
	ControlInfo/W=MiniAnaMain CheckALockedX_tab3
	If(V_value)
		ALocked[npnts] = XLock[npnts] - SetMiniArtifactX
	endIf
	
	//InitialX
	InitialX[npnts] = xcsr(A)
	
	//Isolate
	ControlInfo/W=MiniAnaMain CheckIsolateTag_tab3
	If(V_value)
		Isolate[npnts] = 0
	endIf
	
	//Base
	Base[npnts] = Mean(basefit, (InitialX[npnts] - deltax(basefit)), (InitialX[npnts] + deltax(basefit)))
	
	//Peak
	ControlInfo/W=MiniAnaMain CheckPeak_tab3
	If(V_value)
		Peak[npnts] = ABS(basefit(XLock[npnts]) - Base[npnts])
	endIf
	
	//Area
	ControlInfo/W=MiniAnaMain CheckArea_tab3
	If(V_value)
		Variable area_a = (basefit(xcsr(C))-basefit(xcsr(A)))/(xcsr(C)-xcsr(A))
		Variable area_b = 0.5*(basefit(xcsr(A))+basefit(xcsr(C))-(xcsr(A)+xcsr(C))*area_a)
		Wave MiniArea0 = root:Packages:MiniAna:MiniArea0
		Wave MiniArea1 = root:Packages:MiniAna:MiniArea1
		MiniArea0 = area_a*x+area_b
		MiniArea1 = basefit - MiniArea0
		AreaUC[npnts] = Area(MiniArea1, xcsr(A), xcsr(C))
	endIf
	
	//Decay
	ControlInfo/W=MiniAnaMain CheckDecay_tab3
	If(V_value)
		CurveFit/Q/NTHR = 0 exp_XOffset basefit(xcsr(B), xcsr(C))
		Wave W_coef
		If(W_coef[2]>0&&W_coef[2]<0.02)
			Decay[npnts] = W_coef[2]
		else
			Decay[npnts] = NaN
		endIf

	endIf
	
	//Rise
	ControlInfo/W=MiniAnaMain CheckRise_tab3
	If(V_value)
		Variable RTXLock0
		Variable RTXLock1
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.1*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock0 = V_LevelX
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.9*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock1 = V_LevelX
		If((RTXLock1 - RTXLock0)>0)
			Rise[npnts] = RTXLock1 - RTXLock0
		else
			Rise[npnts] = NaN
		endIf
	endIf
	
	//RecNum
	ControlInfo/W=MiniAnaMain CheckExpRecNum_tab3
	If(V_value)
		RecNum[npnts] = ExpRecNum
	endIf
	
	//Sampling
	ControlInfo/W=MiniAnamain CheckSamplingHz_tab3
	If(V_value)
		Sampling[npnts] = SamplingHz
	endIf
	
	//PCurrent
	ControlInfo/W=MiniAnaMain CheckParentCurrent_tab3
	If(V_value)
		PCurrent[npnts] = SetMiniPCurrent
	endIf
	
	//Error
	ControlInfo/W=MiniAnaMain CheckError_tab3
	If(V_value)
		Error[npnts] = 0
	endIf
	
	//Sorting
	fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String ForSort1 = Wavelist("*", ",", "WIN:MiniAnaTable#T0")
	String ForSort2 = ForSort1[0, (Strlen(T0WL)-1)]
	String t = "Sort/A {wvName, XLock, Serial}," + ForSort2
	Execute t
	SetDataFolder fldrsav0

	//Serial and IEI
	FindLevel /Q Serial, 0
	Variable InsertingPoint = V_LevelX
	Serial[p,] = x + 1
	
	//IEI and LabelingWave
	ControlInfo/W=MiniAnaMain CheckInterEventInterval_tab3
	If(V_value)
		If(InsertingPoint !=0)
			If(StringMatch(wvName[InsertingPoint], wvName[InsertingPoint-1]))
				IEI[InsertingPoint] = XLock[InsertingPoint] - XLock[InsertingPoint - 1]
				If((XLock[InsertingPoint]-XLock[InsertingPoint-1])<0.9*IsoCriteria)
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[InsertingPoint-1]
					lw1[pcsr(D)] = NaN
					luw1[pcsr(D)] = NaN
				else
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[InsertingPoint-1]
					lw1[pcsr(D)] = 1
					luw1[pcsr(D)] = 1
				endIf
				If(numpnts(Serial) != InsertingPoint)
					IEI[InsertingPoint+1] = XLock[InsertingPoint+1] - XLock[InsertingPoint]
				endIf
			else
				IEI[InsertingPoint] = NaN
			endIf
		else
			IEI[InsertingPoint] = NaN
			If(numpnts(Serial)>1)
				IEI[InsertingPoint+1] = XLock[InsertingPoint+1] - XLock[InsertingPoint]
			endIf
		endIf
	endIf
	
	EventSerial = InsertingPoint + 1
	Variable point = InsertingPoint
	
	EventXLock = XLock[point]
	If(StringMatch(EventWaveName,wvName[point]) == 1)
		EventWaveName = wvName[point]
	else
		RemoveFromGraph/W=MiniAnaEventGraph $EventWaveName
		AppendToGraph/W=MiniAnaEventGraph $wvName[point]
		EventWaveName = wvName[point]
	endIf
	SetAxis/W = MiniAnaEventGraph bottom, (EventXLock-0.3*IsoCriteria), (EventXLock+1.1*IsoCriteria)
	
	Cursor/W=MiniAnaEventGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaEventGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaEventGraph C $wvName[point] xcsr(C)
	
//	GetAxis/W = MiniAnaDaughterGraph bottom
//	Variable graphwidth = V_max - V_min
//	SetAxis/W = MiniAnaDaughterGraph bottom, (XLock[point] - 0.2*graphwidth), (XLock[point] + 0.8*graphwidth)

//	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
//	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
//	Cursor/W=MiniAnaDaughterGraph C $wvName[point] XLock[point]+DetectAreaDecayRange

	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	AX = V_min
	RX = V_max - V_min
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	V_max_XD = V_max
	V_min_XD = V_min
	GetAxis/W=MiniAnaDaughterGraph/Q left
	V_max_YD = V_max
	V_min_YD = V_min
	t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)

	ModifyTable/w=MiniAnaTable#T0 selection=(point,0,point,100,0,0)
	
	MiniDispPeak = Peak[point]
	MiniDispArea = AreaUC[point]
	MiniDispRise = Rise[point]
	MiniDispDecay = Decay[point]
	gvError = Error[point]
	
	t_MiniEventLine("")
	
	t_Update_MiniLb2D_Select()
End

Function t_CoAddAll_Mini() //Marquee Control
	SVAR ExpRecNum = root:Packages:MiniAna:ExpRecNum
	SVAR SamplingHz = root:Packages:MiniAna:SamplingHz
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR SetMiniArtifactX = root:Packages:MiniAna:SetMiniArtifactX
	NVAR MiniDispPeak = root:Packages:MiniAna:MiniDispPeak
	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	NVAR SetMiniPCurrent = root:Packages:MiniAna:SetMiniPCurrent
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	NVAR gvError = root:Packages:MiniAna:gvError
	Wave dw = $tWaveMini
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	Wave luw0 = $(tWaveMini + "_Label0")
	Wave luw1 = $(tWaveMini + "_Label1")
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave IEI = root:Packages:MiniAna:IEI
	Wave Base = root:Packages:MiniAna:Base
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUC = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Wave/T Sampling = root:Packages:MiniAna:Sampling
	Wave PCurrent = root:Packages:MiniAna:PCurrent
	Wave Error = root:Packages:MiniAna:Error
	Wave basefit = $(tWaveMini + "_basefit")
	Variable i = 0
	Variable AX, RX, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	String SFL

	//Place Cursors
	String tMinitWin = WinName(0,1)
	GetMarquee bottom
	Cursor/W=$tMinitWin A $tWaveMini V_left
	Cursor/W=$tMinitWin C $tWaveMini V_right
	WaveStats/M=1/Q/R=(V_left, V_right) $tWaveMini
	ControlInfo/W=MiniAnaMain PopupPeakDetect_tab2
	Switch (V_value)
		case 1:
			Cursor/W=$tMinitWin B $tWaveMini V_minLoc
			break;
		case 2:
			Cursor/W=$tMinitWin B $tWaveMini V_maxLoc
			break;
		case 3:
			If(ABS(V_min)>ABS(V_max))
				Cursor/W=$tMinitWin B $tWaveMini V_minLoc
			else
				Cursor/W=$tMinitWin B $tWaveMini V_maxLoc
			endif
			break;
		default:
			break;
	endSwitch

	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0

	Variable PeakXLoc = xcsr(B)
	
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	lw0[pcsr(B)] = 1
	lw1[pcsr(B)] = NaN
	luw0 = lw0
	luw1 = lw1
	
	WaveStats/M=1/Q Serial
	Variable npnts = V_npnts + 1
	i = 0
	do
		SFL = StringFromList(i, T0WL)
		If(Strlen(SFL)<1)
			break
		endIf
		
		Insertpoints npnts, 1, $("root:Packages:MiniAna:" + SFL)
		i += 1
	while(1)
	
	//wvName
	wvName[npnts] = tWaveMini
	
	//wvXLock
	XLock[npnts] = xcsr(B)
	
	//ALocked
	ControlInfo/W=MiniAnaMain CheckALockedX_tab3
	If(V_value)
		ALocked[npnts] = XLock[npnts] - SetMiniArtifactX
	endIf
	
	//InitialX
	InitialX[npnts] = xcsr(A)
	
	//Isolate
	ControlInfo/W=MiniAnaMain CheckIsolateTag_tab3
	If(V_value)
		Isolate[npnts] = 0
	endIf
	
	//Base
	Base[npnts] = Mean(basefit, (InitialX[npnts] - deltax(basefit)), (InitialX[npnts] + deltax(basefit)))
	
	//Peak
	ControlInfo/W=MiniAnaMain CheckPeak_tab3
	If(V_value)
		Peak[npnts] = ABS(basefit(XLock[npnts]) - Base[npnts])
	endIf
	
	//Area
	ControlInfo/W=MiniAnaMain CheckArea_tab3
	If(V_value)
		Variable area_a = (basefit(xcsr(C))-basefit(xcsr(A)))/(xcsr(C)-xcsr(A))
		Variable area_b = 0.5*(basefit(xcsr(A))+basefit(xcsr(C))-(xcsr(A)+xcsr(C))*area_a)
		Wave MiniArea0 = root:Packages:MiniAna:MiniArea0
		Wave MiniArea1 = root:Packages:MiniAna:MiniArea1
		MiniArea0 = area_a*x+area_b
		MiniArea1 = basefit - MiniArea0
		AreaUC[npnts] = Area(MiniArea1, xcsr(A), xcsr(C))
	endIf
	
	//Decay
	ControlInfo/W=MiniAnaMain CheckDecay_tab3
	If(V_value)
		CurveFit/Q/NTHR = 0 exp_XOffset basefit(xcsr(B), xcsr(C))
		Wave W_coef
		If(W_coef[2]>0&&W_coef[2]<0.02)
			Decay[npnts] = W_coef[2]
		else
			Decay[npnts] = NaN
		endIf

	endIf
	
	//Rise
	ControlInfo/W=MiniAnaMain CheckRise_tab3
	If(V_value)
		Variable RTXLock0
		Variable RTXLock1
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.1*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock0 = V_LevelX
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.9*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock1 = V_LevelX
		If((RTXLock1 - RTXLock0)>0)
			Rise[npnts] = RTXLock1 - RTXLock0
		else
			Rise[npnts] = NaN
		endIf
	endIf
	
	//RecNum
	ControlInfo/W=MiniAnaMain CheckExpRecNum_tab3
	If(V_value)
		RecNum[npnts] = ExpRecNum
	endIf
	
	//Sampling
	ControlInfo/W=MiniAnamain CheckSamplingHz_tab3
	If(V_value)
		Sampling[npnts] = SamplingHz
	endIf
	
	//PCurrent
	ControlInfo/W=MiniAnaMain CheckParentCurrent_tab3
	If(V_value)
		PCurrent[npnts] = SetMiniPCurrent
	endIf
	
	//Error
	ControlInfo/W=MiniAnaMain CheckError_tab3
	If(V_value)
		Error[npnts] = 0
	endIf
	
	//Sorting
	fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String ForSort1 = Wavelist("*", ",", "WIN:MiniAnaTable#T0")
	String ForSort2 = ForSort1[0, (Strlen(T0WL)-1)]
	String t = "Sort/A {wvName, XLock, Serial}," + ForSort2
	Execute t
	SetDataFolder fldrsav0

	//Serial and IEI
	FindLevel /Q Serial, 0
	Variable InsertingPoint = V_LevelX
	Serial[p,] = x + 1
	
	//IEI and LabelingWave
	ControlInfo/W=MiniAnaMain CheckInterEventInterval_tab3
	If(V_value)
		If(InsertingPoint !=0)
			If(StringMatch(wvName[InsertingPoint], wvName[InsertingPoint-1]))
				IEI[InsertingPoint] = XLock[InsertingPoint] - XLock[InsertingPoint - 1]
				If((XLock[InsertingPoint]-XLock[InsertingPoint-1])<0.9*IsoCriteria)
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[InsertingPoint-1]
					lw1[pcsr(D)] = NaN
					luw1[pcsr(D)] = NaN
				else
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[InsertingPoint-1]
					lw1[pcsr(D)] = 1
					luw1[pcsr(D)] = 1
				endIf
				If(numpnts(Serial) != InsertingPoint)
					IEI[InsertingPoint+1] = XLock[InsertingPoint+1] - XLock[InsertingPoint]
				endIf
			else
				IEI[InsertingPoint] = NaN
			endIf
		else
			IEI[InsertingPoint] = NaN
			If(numpnts(Serial)>1)
				IEI[InsertingPoint+1] = XLock[InsertingPoint+1] - XLock[InsertingPoint]
			endIf
		endIf
	endIf
	
	EventSerial = InsertingPoint + 1
	Variable point = InsertingPoint
	
	EventXLock = XLock[point]
	If(StringMatch(EventWaveName,wvName[point]) == 1)
		EventWaveName = wvName[point]
	else
		RemoveFromGraph/W=MiniAnaEventGraph $EventWaveName
		AppendToGraph/W=MiniAnaEventGraph $wvName[point]
		EventWaveName = wvName[point]
	endIf
	SetAxis/W = MiniAnaEventGraph bottom, (EventXLock-0.3*IsoCriteria), (EventXLock+1.1*IsoCriteria)
	
	Cursor/W=MiniAnaEventGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaEventGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaEventGraph C $wvName[point] xcsr(C)
	
//	GetAxis/W = MiniAnaDaughterGraph bottom
//	Variable graphwidth = V_max - V_min
//	SetAxis/W = MiniAnaDaughterGraph bottom, (XLock[point] - 0.2*graphwidth), (XLock[point] + 0.8*graphwidth)

//	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
//	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
//	Cursor/W=MiniAnaDaughterGraph C $wvName[point] XLock[point]+DetectAreaDecayRange

	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	AX = V_min
	RX = V_max - V_min
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	V_max_XD = V_max
	V_min_XD = V_min
	GetAxis/W=MiniAnaDaughterGraph/Q left
	V_max_YD = V_max
	V_min_YD = V_min
	t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)

	ModifyTable/w=MiniAnaTable#T0 selection=(point,0,point,100,0,0)
	
	MiniDispPeak = Peak[point]
	MiniDispArea = AreaUC[point]
	MiniDispRise = Rise[point]
	MiniDispDecay = Decay[point]
	gvError = Error[point]
	
	t_MiniEventLine("")
	
	t_Update_MiniLb2D_Select()
End

Function t_MiniIsoMdAll(ctrlName) : ButtonControl
	String ctrlName
	SVAR ExpRecNum = root:Packages:MiniAna:ExpRecNum
	SVAR SamplingHz = root:Packages:MiniAna:SamplingHz
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR SetMiniArtifactX = root:Packages:MiniAna:SetMiniArtifactX
	NVAR MiniDispPeak = root:Packages:MiniAna:MiniDispPeak
	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	NVAR SetMiniPCurrent = root:Packages:MiniAna:SetMiniPCurrent
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	NVAR gvError = root:Packages:MiniAna:gvError
	Wave dw = $tWaveMini
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	Wave luw0 = $(tWaveMini + "_Label0")
	Wave luw1 = $(tWaveMini + "_Label1")
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave IEI = root:Packages:MiniAna:IEI
	Wave Base = root:Packages:MiniAna:Base
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUC = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Wave/T Sampling = root:Packages:MiniAna:Sampling
	Wave PCurrent = root:Packages:MiniAna:PCurrent
	Wave Error = root:Packages:MiniAna:Error
	Wave basefit = $(tWaveMini + "_basefit")
	Variable i = 0
	Variable AX, RX, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	String SFL

	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0

	Variable PeakXLoc = xcsr(B)
	
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini XLock[EventSerial-1]
	Cursor/W=MiniAnaEventGraph B $tWaveMini XLock[EventSerial-1]
	lw0[pcsr(B)] = NaN
	lw1[pcsr(B)] = NaN	
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	Cursor/W=MiniAnaEventGraph B $tWaveMini PeakXLoc
	lw0[pcsr(B)] = 1
	lw1[pcsr(B)] = 1
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	Cursor/W=MiniAnaEventGraph B $tWaveMini PeakXLoc
	luw0 = lw0
	luw1 = lw1
	
	Variable npnts = EventSerial - 1
	//wvName
	wvName[npnts] = tWaveMini
	
	//wvXLock
	XLock[npnts] = xcsr(B)
	
	//ALocked
	ControlInfo/W=MiniAnaMain CheckALockedX_tab3
	If(V_value)
		ALocked[npnts] = XLock[npnts] - SetMiniArtifactX
	endIf
	
	//InitialX
	InitialX[npnts] = xcsr(A)
	
	//Isolate
	ControlInfo/W=MiniAnaMain CheckIsolateTag_tab3
	If(V_value)
		Isolate[npnts] = 1
	endIf
	
	//Base
	Base[npnts] = Mean(basefit, (InitialX[npnts] - deltax(basefit)), (InitialX[npnts] + deltax(basefit)))
	
	//Peak
	ControlInfo/W=MiniAnaMain CheckPeak_tab3
	If(V_value)
		Peak[npnts] = ABS(basefit(XLock[npnts]) - Base[npnts])
	endIf
	
	//Area
	ControlInfo/W=MiniAnaMain CheckArea_tab3
	If(V_value)
		Variable area_a = (basefit(xcsr(C))-basefit(xcsr(A)))/(xcsr(C)-xcsr(A))
		Variable area_b = 0.5*(basefit(xcsr(A))+basefit(xcsr(C))-(xcsr(A)+xcsr(C))*area_a)
		Wave MiniArea0 = root:Packages:MiniAna:MiniArea0
		Wave MiniArea1 = root:Packages:MiniAna:MiniArea1
		MiniArea0 = area_a*x+area_b
		MiniArea1 = basefit - MiniArea0
		AreaUC[npnts] = Area(MiniArea1, xcsr(A), xcsr(C))
	endIf
	
	//Decay
	ControlInfo/W=MiniAnaMain CheckDecay_tab3
	If(V_value)
		CurveFit/Q/NTHR = 0 exp_XOffset basefit(xcsr(B), xcsr(C))
		Wave W_coef
		If(W_coef[2]>0&&W_coef[2]<0.02)
			Decay[npnts] = W_coef[2]
		else
			Decay[npnts] = NaN
		endIf

	endIf
	
	//Rise
	ControlInfo/W=MiniAnaMain CheckRise_tab3
	If(V_value)
		Variable RTXLock0
		Variable RTXLock1
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.1*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock0 = V_LevelX
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.9*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock1 = V_LevelX
		If((RTXLock1 - RTXLock0)>0)
			Rise[npnts] = RTXLock1 - RTXLock0
		else
			Rise[npnts] = NaN
		endIf
	endIf
	
	//RecNum
	ControlInfo/W=MiniAnaMain CheckExpRecNum_tab3
	If(V_value)
		RecNum[npnts] = ExpRecNum
	endIf
	
	//Sampling
	ControlInfo/W=MiniAnamain CheckSamplingHz_tab3
	If(V_value)
		Sampling[npnts] = SamplingHz
	endIf
	
	//PCurrent
	ControlInfo/W=MiniAnaMain CheckParentCurrent_tab3
	If(V_value)
		PCurrent[npnts] = SetMiniPCurrent
	endIf
	
	//Error
	ControlInfo/W=MiniAnaMain CheckError_tab3
	If(V_value)
		Error[npnts] = 0
	endIf
	
	//Sorting
//	fldrsav0 = GetDataFolder(1)
//	SetDataFolder root:Packages:MiniAna:
//	String ForSort1 = Wavelist("*", ",", "WIN:MiniAnaTable#T0")
//	String ForSort2 = ForSort1[0, (Strlen(T0WL)-1)]
//	String t = "Sort/A {wvName, XLock, Serial}," + ForSort2
//	Execute t
//	SetDataFolder fldrsav0

	//Serial and IEI
//	FindLevel /Q Serial, 0
//	Variable InsertingPoint = V_LevelX
//	Serial[p,] = x + 1
	
	//IEI and LabelingWave
	ControlInfo/W=MiniAnaMain CheckInterEventInterval_tab3
	If(V_value)
		If(npnts !=0)
			If(StringMatch(wvName[npnts], wvName[npnts-1]))
				IEI[npnts] = XLock[npnts] - XLock[npnts - 1]
				If((XLock[npnts]-XLock[npnts-1])<0.9*IsoCriteria)
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[npnts-1]
					lw1[pcsr(D, "MiniAnaDaughterGraph")] = NaN
					luw1[pcsr(D, "MiniAnaDaughterGraph")] = NaN
					Isolate[npnts-1] = 0
				else
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[npnts-1]
//					lw1[pcsr(D, "MiniAnaDaughterGraph")] = 1
//					luw1[pcsr(D, "MiniAnaDaughterGraph")] = 1
//					Isolate[npnts-1] = 1
				endIf
				If(numpnts(Serial) != npnts)
					IEI[npnts+1] = XLock[npnts+1] - XLock[npnts]
					Cursor/W=MinianaDaughterGraph F $tWaveMini XLock[npnts+1]
					lw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
					luw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
					Isolate[npnts+1] = 1
				endIf
			else
				IEI[npnts] = NaN
			endIf
		else
			IEI[npnts] = NaN
			If(numpnts(Serial)>1)
				IEI[npnts+1] = XLock[npnts+1] - XLock[npnts]
				Cursor/W=MinianaDaughterGraph F $tWaveMini XLock[npnts+1]
				lw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
				luw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
				Isolate[npnts+1]= 1
			endIf
		endIf
	endIf
	
	EventSerial = npnts + 1
	Variable point = npnts
	
	EventXLock = XLock[point]
	If(StringMatch(EventWaveName,wvName[point]) == 1)
		EventWaveName = wvName[point]
	else
		RemoveFromGraph/W=MiniAnaEventGraph $EventWaveName
		AppendToGraph/W=MiniAnaEventGraph $wvName[point]
		EventWaveName = wvName[point]
	endIf
	SetAxis/W = MiniAnaEventGraph bottom, (EventXLock-0.3*IsoCriteria), (EventXLock+1.1*IsoCriteria)
	
	Cursor/W=MiniAnaEventGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaEventGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaEventGraph C $wvName[point] xcsr(C)
	
	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaDaughterGraph C $wvName[point] xcsr(C)
	
//	GetAxis/W = MiniAnaDaughterGraph bottom
//	Variable graphwidth = V_max - V_min
//	SetAxis/W = MiniAnaDaughterGraph bottom, (XLock[point] - 0.2*graphwidth), (XLock[point] + 0.8*graphwidth)

//	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
//	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
//	Cursor/W=MiniAnaDaughterGraph C $wvName[point] XLock[point]+DetectAreaDecayRange

	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	AX = V_min
	RX = V_max - V_min
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	V_max_XD = V_max
	V_min_XD = V_min
	GetAxis/W=MiniAnaDaughterGraph/Q left
	V_max_YD = V_max
	V_min_YD = V_min
	t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)

	ModifyTable/w=MiniAnaTable#T0 selection=(point,0,point,100,0,0)
	
	//Update display
	MiniDispPeak = Peak[point]
	MiniDispArea = AreaUC[point]
	MiniDispRise = Rise[point]
	MiniDispDecay = Decay[point]
	gvError = Error[point]
	
	t_MiniEventLine("")
	
	t_Update_MiniLb2D_Select()
End

Function t_IsoModAll_Mini() //Marquee Control
	SVAR ExpRecNum = root:Packages:MiniAna:ExpRecNum
	SVAR SamplingHz = root:Packages:MiniAna:SamplingHz
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR SetMiniArtifactX = root:Packages:MiniAna:SetMiniArtifactX
	NVAR MiniDispPeak = root:Packages:MiniAna:MiniDispPeak
	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	NVAR SetMiniPCurrent = root:Packages:MiniAna:SetMiniPCurrent
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	NVAR gvError = root:Packages:MiniAna:gvError
	Wave dw = $tWaveMini
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	Wave luw0 = $(tWaveMini + "_Label0")
	Wave luw1 = $(tWaveMini + "_Label1")
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave IEI = root:Packages:MiniAna:IEI
	Wave Base = root:Packages:MiniAna:Base
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUC = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Wave/T Sampling = root:Packages:MiniAna:Sampling
	Wave PCurrent = root:Packages:MiniAna:PCurrent
	Wave Error = root:Packages:MiniAna:Error
	Wave basefit = $(tWaveMini + "_basefit")
	Variable i = 0
	Variable AX, RX, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	String SFL

	//Place Cursors
	String tMinitWin = WinName(0,1)
	GetMarquee bottom
	Cursor/W=$tMinitWin A $tWaveMini V_left
	Cursor/W=$tMinitWin C $tWaveMini V_right
	WaveStats/M=1/Q/R=(V_left, V_right) $tWaveMini
	ControlInfo/W=MiniAnaMain PopupPeakDetect_tab2
	Switch (V_value)
		case 1:
			Cursor/W=$tMinitWin B $tWaveMini V_minLoc
			break;
		case 2:
			Cursor/W=$tMinitWin B $tWaveMini V_maxLoc
			break;
		case 3:
			If(ABS(V_min)>ABS(V_max))
				Cursor/W=$tMinitWin B $tWaveMini V_minLoc
			else
				Cursor/W=$tMinitWin B $tWaveMini V_maxLoc
			endif
			break;
		default:
			break;
	endSwitch

	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0

	Variable PeakXLoc = xcsr(B)
	
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini XLock[EventSerial-1]
	Cursor/W=MiniAnaEventGraph B $tWaveMini XLock[EventSerial-1]
	lw0[pcsr(B)] = NaN
	lw1[pcsr(B)] = NaN	
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	Cursor/W=MiniAnaEventGraph B $tWaveMini PeakXLoc
	lw0[pcsr(B)] = 1
	lw1[pcsr(B)] = 1
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	Cursor/W=MiniEventGraph B $tWaveMini PeakXLoc
	luw0 = lw0
	luw1 = lw1
	
	Variable npnts = EventSerial - 1
	//wvName
	wvName[npnts] = tWaveMini
	
	//wvXLock
	XLock[npnts] = xcsr(B)
	
	//ALocked
	ControlInfo/W=MiniAnaMain CheckALockedX_tab3
	If(V_value)
		ALocked[npnts] = XLock[npnts] - SetMiniArtifactX
	endIf
	
	//InitialX
	InitialX[npnts] = xcsr(A)
	
	//Isolate
	ControlInfo/W=MiniAnaMain CheckIsolateTag_tab3
	If(V_value)
		Isolate[npnts] = 1
	endIf
	
	//Base
	Base[npnts] = Mean(basefit, (InitialX[npnts] - deltax(basefit)), (InitialX[npnts] + deltax(basefit)))
	
	//Peak
	ControlInfo/W=MiniAnaMain CheckPeak_tab3
	If(V_value)
		Peak[npnts] = ABS(basefit(XLock[npnts]) - Base[npnts])
	endIf
	
	//Area
	ControlInfo/W=MiniAnaMain CheckArea_tab3
	If(V_value)
		Variable area_a = (basefit(xcsr(C))-basefit(xcsr(A)))/(xcsr(C)-xcsr(A))
		Variable area_b = 0.5*(basefit(xcsr(A))+basefit(xcsr(C))-(xcsr(A)+xcsr(C))*area_a)
		Wave MiniArea0 = root:Packages:MiniAna:MiniArea0
		Wave MiniArea1 = root:Packages:MiniAna:MiniArea1
		MiniArea0 = area_a*x+area_b
		MiniArea1 = basefit - MiniArea0
		AreaUC[npnts] = Area(MiniArea1, xcsr(A), xcsr(C))
	endIf
	
	//Decay
	ControlInfo/W=MiniAnaMain CheckDecay_tab3
	If(V_value)
		CurveFit/Q/NTHR = 0 exp_XOffset basefit(xcsr(B), xcsr(C))
		Wave W_coef
		If(W_coef[2]>0&&W_coef[2]<0.02)
			Decay[npnts] = W_coef[2]
		else
			Decay[npnts] = NaN
		endIf

	endIf
	
	//Rise
	ControlInfo/W=MiniAnaMain CheckRise_tab3
	If(V_value)
		Variable RTXLock0
		Variable RTXLock1
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.1*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock0 = V_LevelX
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.9*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock1 = V_LevelX
		If((RTXLock1 - RTXLock0)>0)
			Rise[npnts] = RTXLock1 - RTXLock0
		else
			Rise[npnts] = NaN
		endIf
	endIf
	
	//RecNum
	ControlInfo/W=MiniAnaMain CheckExpRecNum_tab3
	If(V_value)
		RecNum[npnts] = ExpRecNum
	endIf
	
	//Sampling
	ControlInfo/W=MiniAnamain CheckSamplingHz_tab3
	If(V_value)
		Sampling[npnts] = SamplingHz
	endIf
	
	//PCurrent
	ControlInfo/W=MiniAnaMain CheckParentCurrent_tab3
	If(V_value)
		PCurrent[npnts] = SetMiniPCurrent
	endIf
	
	//Error
	ControlInfo/W=MiniAnaMain CheckError_tab3
	If(V_value)
		Error[npnts] = 0
	endIf
	
	//Sorting
//	fldrsav0 = GetDataFolder(1)
//	SetDataFolder root:Packages:MiniAna:
//	String ForSort1 = Wavelist("*", ",", "WIN:MiniAnaTable#T0")
//	String ForSort2 = ForSort1[0, (Strlen(T0WL)-1)]
//	String t = "Sort/A {wvName, XLock, Serial}," + ForSort2
//	Execute t
//	SetDataFolder fldrsav0

	//Serial and IEI
//	FindLevel /Q Serial, 0
//	Variable InsertingPoint = V_LevelX
//	Serial[p,] = x + 1
	
	//IEI and LabelingWave
	ControlInfo/W=MiniAnaMain CheckInterEventInterval_tab3
	If(V_value)
		If(npnts !=0)
			If(StringMatch(wvName[npnts], wvName[npnts-1]))
				IEI[npnts] = XLock[npnts] - XLock[npnts - 1]
				If((XLock[npnts]-XLock[npnts-1])<0.9*IsoCriteria)
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[npnts-1]
					lw1[pcsr(D, "MiniAnaDaughterGraph")] = NaN
					luw1[pcsr(D, "MiniAnaDaughterGraph")] = NaN
					Isolate[npnts-1] = 0
				else
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[npnts-1]
//					lw1[pcsr(D, "MiniAnaDaughterGraph")] = 1
//					luw1[pcsr(D, "MiniAnaDaughterGraph")] = 1
//					Isolate[npnts-1] = 1
				endIf
				If(numpnts(Serial) != npnts)
					IEI[npnts+1] = XLock[npnts+1] - XLock[npnts]
					Cursor/W=MinianaDaughterGraph F $tWaveMini XLock[npnts+1]
					lw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
					luw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
					Isolate[npnts+1] = 1
				endIf
			else
				IEI[npnts] = NaN
			endIf
		else
			IEI[npnts] = NaN
			If(numpnts(Serial)>1)
				IEI[npnts+1] = XLock[npnts+1] - XLock[npnts]
				Cursor/W=MinianaDaughterGraph F $tWaveMini XLock[npnts+1]
				lw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
				luw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
				Isolate[npnts+1]= 1
			endIf
		endIf
	endIf
	
	EventSerial = npnts + 1
	Variable point = npnts
	
	EventXLock = XLock[point]
	If(StringMatch(EventWaveName,wvName[point]) == 1)
		EventWaveName = wvName[point]
	else
		RemoveFromGraph/W=MiniAnaEventGraph $EventWaveName
		AppendToGraph/W=MiniAnaEventGraph $wvName[point]
		EventWaveName = wvName[point]
	endIf
	SetAxis/W = MiniAnaEventGraph bottom, (EventXLock-0.3*IsoCriteria), (EventXLock+1.1*IsoCriteria)
	
	Cursor/W=MiniAnaEventGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaEventGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaEventGraph C $wvName[point] xcsr(C)

	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaDaughterGraph C $wvName[point] xcsr(C)

//	GetAxis/W = MiniAnaDaughterGraph bottom
//	Variable graphwidth = V_max - V_min
//	SetAxis/W = MiniAnaDaughterGraph bottom, (XLock[point] - 0.2*graphwidth), (XLock[point] + 0.8*graphwidth)

//	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
//	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
//	Cursor/W=MiniAnaDaughterGraph C $wvName[point] XLock[point]+DetectAreaDecayRange

	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	AX = V_min
	RX = V_max - V_min
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	V_max_XD = V_max
	V_min_XD = V_min
	GetAxis/W=MiniAnaDaughterGraph/Q left
	V_max_YD = V_max
	V_min_YD = V_min
	t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)

	ModifyTable/w=MiniAnaTable#T0 selection=(point,0,point,100,0,0)
	
	MiniDispPeak = Peak[point]
	MiniDispArea = AreaUC[point]
	MiniDispRise = Rise[point]
	MiniDispDecay = Decay[point]
	gvError = Error[point]
	
	t_MiniEventLine("")
	
	t_Update_MiniLb2D_Select()
End

Function t_MiniCoMdAll(ctrlName) : ButtonControl
	String ctrlName
	SVAR ExpRecNum = root:Packages:MiniAna:ExpRecNum
	SVAR SamplingHz = root:Packages:MiniAna:SamplingHz
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR SetMiniArtifactX = root:Packages:MiniAna:SetMiniArtifactX
	NVAR MiniDispPeak = root:Packages:MiniAna:MiniDispPeak
	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	NVAR SetMiniPCurrent = root:Packages:MiniAna:SetMiniPCurrent
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	NVAR gvError = root:Packages:MiniAna:gvError
	Wave dw = $tWaveMini
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	Wave luw0 = $(tWaveMini + "_Label0")
	Wave luw1 = $(tWaveMini + "_Label1")
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave IEI = root:Packages:MiniAna:IEI
	Wave Base = root:Packages:MiniAna:Base
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUC = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Wave/T Sampling = root:Packages:MiniAna:Sampling
	Wave PCurrent = root:Packages:MiniAna:PCurrent
	Wave Error = root:Packages:MiniAna:Error
	Wave basefit = $(tWaveMini + "_basefit")
	Variable i = 0
	Variable AX, RX, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	String SFL

	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0

	Variable PeakXLoc = xcsr(B)
	
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini XLock[EventSerial-1]
	Cursor/W=MiniAnaEventGraph B $tWaveMini XLock[EventSerial-1]
	lw0[pcsr(B)] = NaN
	lw1[pcsr(B)] = NaN	
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	Cursor/W=MiniAnaEventGraph B $tWaveMini PeakXLoc
	lw0[pcsr(B)] = 1
	lw1[pcsr(B)] = NaN
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	Cursor/W=MiniAnaEventGraph B $tWaveMini PeakXLoc
	luw0 = lw0
	luw1 = lw1
	
	Variable npnts = EventSerial - 1
	//wvName
	wvName[npnts] = tWaveMini
	
	//wvXLock
	XLock[npnts] = xcsr(B)
	
	//ALocked
	ControlInfo/W=MiniAnaMain CheckALockedX_tab3
	If(V_value)
		ALocked[npnts] = XLock[npnts] - SetMiniArtifactX
	endIf
	
	//InitialX
	InitialX[npnts] = xcsr(A)
	
	//Isolate
	ControlInfo/W=MiniAnaMain CheckIsolateTag_tab3
	If(V_value)
		Isolate[npnts] = 0
	endIf
	
	//Base
	Base[npnts] = Mean(basefit, (InitialX[npnts] - deltax(basefit)), (InitialX[npnts] + deltax(basefit)))
	
	//Peak
	ControlInfo/W=MiniAnaMain CheckPeak_tab3
	If(V_value)
		Peak[npnts] = ABS(basefit(XLock[npnts]) - Base[npnts])
	endIf
	
	//Area
	ControlInfo/W=MiniAnaMain CheckArea_tab3
	If(V_value)
		Variable area_a = (basefit(xcsr(C))-basefit(xcsr(A)))/(xcsr(C)-xcsr(A))
		Variable area_b = 0.5*(basefit(xcsr(A))+basefit(xcsr(C))-(xcsr(A)+xcsr(C))*area_a)
		Wave MiniArea0 = root:Packages:MiniAna:MiniArea0
		Wave MiniArea1 = root:Packages:MiniAna:MiniArea1
		MiniArea0 = area_a*x+area_b
		MiniArea1 = basefit - MiniArea0
		AreaUC[npnts] = Area(MiniArea1, xcsr(A), xcsr(C))
	endIf
	
	//Decay
	ControlInfo/W=MiniAnaMain CheckDecay_tab3
	If(V_value)
		CurveFit/Q/NTHR = 0 exp_XOffset basefit(xcsr(B), xcsr(C))
		Wave W_coef
		If(W_coef[2]>0&&W_coef[2]<0.02)
			Decay[npnts] = W_coef[2]
		else
			Decay[npnts] = NaN
		endIf

	endIf
	
	//Rise
	ControlInfo/W=MiniAnaMain CheckRise_tab3
	If(V_value)
		Variable RTXLock0
		Variable RTXLock1
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.1*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock0 = V_LevelX
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.9*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock1 = V_LevelX
		If((RTXLock1 - RTXLock0)>0)
			Rise[npnts] = RTXLock1 - RTXLock0
		else
			Rise[npnts] = NaN
		endIf
	endIf
	
	//RecNum
	ControlInfo/W=MiniAnaMain CheckExpRecNum_tab3
	If(V_value)
		RecNum[npnts] = ExpRecNum
	endIf
	
	//Sampling
	ControlInfo/W=MiniAnamain CheckSamplingHz_tab3
	If(V_value)
		Sampling[npnts] = SamplingHz
	endIf
	
	//PCurrent
	ControlInfo/W=MiniAnaMain CheckParentCurrent_tab3
	If(V_value)
		PCurrent[npnts] = SetMiniPCurrent
	endIf
	
	//Error
	ControlInfo/W=MiniAnaMain CheckError_tab3
	If(V_value)
		Error[npnts] = 0
	endIf
	
	//Sorting
//	fldrsav0 = GetDataFolder(1)
//	SetDataFolder root:Packages:MiniAna:
//	String ForSort1 = Wavelist("*", ",", "WIN:MiniAnaTable#T0")
//	String ForSort2 = ForSort1[0, (Strlen(T0WL)-1)]
//	String t = "Sort/A {wvName, XLock, Serial}," + ForSort2
//	Execute t
//	SetDataFolder fldrsav0

	//Serial and IEI
//	FindLevel /Q Serial, 0
//	Variable InsertingPoint = V_LevelX
//	Serial[p,] = x + 1
	
	//IEI and LabelingWave
	ControlInfo/W=MiniAnaMain CheckInterEventInterval_tab3
	If(V_value)
		If(npnts !=0)
			If(StringMatch(wvName[npnts], wvName[npnts-1]))
				IEI[npnts] = XLock[npnts] - XLock[npnts - 1]
				If((XLock[npnts]-XLock[npnts-1])<0.9*IsoCriteria)
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[npnts-1]
					lw1[pcsr(D, "MiniAnaDaughterGraph")] = NaN
					luw1[pcsr(D, "MiniAnaDaughterGraph")] = NaN
					Isolate[npnts-1] = 0
				else
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[npnts-1]
					lw1[pcsr(D, "MiniAnaDaughterGraph")] = 1
					luw1[pcsr(D, "MiniAnaDaughterGraph")] = 1
					Isolate[npnts-1] = 1
				endIf
				If(numpnts(Serial) != npnts)
					IEI[npnts+1] = XLock[npnts+1] - XLock[npnts]
					If((XLock[npnts+1]-XLock[npnts])>0.1*IsoCriteria&&(XLock[npnts+2]-XLock[npnts+1])>0.9*IsoCriteria)
						Cursor/W=MinianaDaughterGraph F $tWaveMini XLock[npnts+1]
						lw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
						luw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
						Isolate[npnts+1] = 1
					else
						Cursor/W=MinianaDaughterGraph F $tWaveMini XLock[npnts+1]
//						lw1[pcsr(F, "MiniAnaDaughterGraph")] = 0
//						luw1[pcsr(F, "MiniAnaDaughterGraph")] = 0
						lw1[pcsr(F, "MiniAnaDaughterGraph")] = NaN
						luw1[pcsr(F, "MiniAnaDaughterGraph")] = NaN
						Isolate[npnts+1] = 0
					endIf				
				endIf
			else
				IEI[npnts] = NaN
			endIf
		else
			IEI[npnts] = NaN
			If(numpnts(Serial)>1)
				IEI[npnts+1] = XLock[npnts+1] - XLock[npnts]
				Cursor/W=MinianaDaughterGraph F $tWaveMini XLock[npnts+1]
				lw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
				luw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
				Isolate[npnts+1] = 1
			endIf
		endIf
	endIf
	
	EventSerial = npnts + 1
	Variable point = npnts
	
	EventXLock = XLock[point]
	If(StringMatch(EventWaveName,wvName[point]) == 1)
		EventWaveName = wvName[point]
	else
		RemoveFromGraph/W=MiniAnaEventGraph $EventWaveName
		AppendToGraph/W=MiniAnaEventGraph $wvName[point]
		EventWaveName = wvName[point]
	endIf
	SetAxis/W = MiniAnaEventGraph bottom, (EventXLock-0.3*IsoCriteria), (EventXLock+1.1*IsoCriteria)
	
	Cursor/W=MiniAnaEventGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaEventGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaEventGraph C $wvName[point] xcsr(C)
	
	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaDaughterGraph C $wvName[point] xcsr(C)
	
//	GetAxis/W = MiniAnaDaughterGraph bottom
//	Variable graphwidth = V_max - V_min
//	SetAxis/W = MiniAnaDaughterGraph bottom, (XLock[point] - 0.2*graphwidth), (XLock[point] + 0.8*graphwidth)

//	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
//	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
//	Cursor/W=MiniAnaDaughterGraph C $wvName[point] XLock[point]+DetectAreaDecayRange

	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	AX = V_min
	RX = V_max - V_min
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	V_max_XD = V_max
	V_min_XD = V_min
	GetAxis/W=MiniAnaDaughterGraph/Q left
	V_max_YD = V_max
	V_min_YD = V_min
	t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)

	ModifyTable/w=MiniAnaTable#T0 selection=(point,0,point,100,0,0)
	
	//Update display
	MiniDispPeak = Peak[point]
	MiniDispArea = AreaUC[point]
	MiniDispRise = Rise[point]
	MiniDispDecay = Decay[point]
	gvError = Error[point]
	
	t_MiniEventLine("")
	
	t_Update_MiniLb2D_Select()
End

Function t_CoModAll_Mini() //Marquee Control
	SVAR ExpRecNum = root:Packages:MiniAna:ExpRecNum
	SVAR SamplingHz = root:Packages:MiniAna:SamplingHz
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR SetMiniArtifactX = root:Packages:MiniAna:SetMiniArtifactX
	NVAR MiniDispPeak = root:Packages:MiniAna:MiniDispPeak
	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	NVAR SetMiniPCurrent = root:Packages:MiniAna:SetMiniPCurrent
	NVAR IsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	NVAR gvError = root:Packages:MiniAna:gvError
	Wave dw = $tWaveMini
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	Wave luw0 = $(tWaveMini + "_Label0")
	Wave luw1 = $(tWaveMini + "_Label1")
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave IEI = root:Packages:MiniAna:IEI
	Wave Base = root:Packages:MiniAna:Base
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUC = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave/T RecNum = root:Packages:MiniAna:RecNum
	Wave/T Sampling = root:Packages:MiniAna:Sampling
	Wave PCurrent = root:Packages:MiniAna:PCurrent
	Wave Error = root:Packages:MiniAna:Error
	Wave basefit = $(tWaveMini + "_basefit")
	Variable i = 0
	Variable AX, RX, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	String SFL
	
	//Place Cursors
	String tMinitWin = WinName(0,1)
	GetMarquee bottom
	Cursor/W=$tMinitWin A $tWaveMini V_left
	Cursor/W=$tMinitWin C $tWaveMini V_right
	WaveStats/M=1/Q/R=(V_left, V_right) $tWaveMini
	ControlInfo/W=MiniAnaMain PopupPeakDetect_tab2
	Switch (V_value)
		case 1:
			Cursor/W=$tMinitWin B $tWaveMini V_minLoc
			break;
		case 2:
			Cursor/W=$tMinitWin B $tWaveMini V_maxLoc
			break;
		case 3:
			If(ABS(V_min)>ABS(V_max))
				Cursor/W=$tMinitWin B $tWaveMini V_minLoc
			else
				Cursor/W=$tMinitWin B $tWaveMini V_maxLoc
			endif
			break;
		default:
			break;
	endSwitch

	String fldrsav0 = GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	String T0WL = Wavelist("*", ";", "WIN:MiniAnaTable#T0")
	SetDataFolder fldrsav0

	Variable PeakXLoc = xcsr(B)
	
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini XLock[EventSerial-1]
	Cursor/W=MiniAnaEventGraph B $tWaveMini XLock[EventSerial-1]
	lw0[pcsr(B)] = NaN
	lw1[pcsr(B)] = NaN	
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	Cursor/W=MiniAnaEventGraph B $tWaveMini PeakXLoc
	lw0[pcsr(B)] = 1
	lw1[pcsr(B)] = NaN
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	Cursor/W=MiniAnaEventGraph B $tWaveMini PeakXLoc
	lw0[pcsr(B)] = NaN
	lw1[pcsr(B)] = NaN	
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	Cursor/W=MiniAnaEventGraph B $tWaveMini PeakXLoc
	lw0[pcsr(B)] = 1
	lw1[pcsr(B)] = NaN
	Cursor/W=MiniAnaDaughterGraph B $tWaveMini PeakXLoc
	Cursor/W=MiniAnaEventGraph B $tWaveMini PeakXLoc
	luw0 = lw0
	luw1 = lw1
	
	Variable npnts = EventSerial - 1
	//wvName
	wvName[npnts] = tWaveMini
	
	//wvXLock
	XLock[npnts] = xcsr(B)
	
	//ALocked
	ControlInfo/W=MiniAnaMain CheckALockedX_tab3
	If(V_value)
		ALocked[npnts] = XLock[npnts] - SetMiniArtifactX
	endIf
	
	//InitialX
	InitialX[npnts] = xcsr(A)
	
	//Isolate
	ControlInfo/W=MiniAnaMain CheckIsolateTag_tab3
	If(V_value)
		Isolate[npnts] = 0
	endIf
	
	//Base
	Base[npnts] = Mean(basefit, (InitialX[npnts] - deltax(basefit)), (InitialX[npnts] + deltax(basefit)))
	
	//Peak
	ControlInfo/W=MiniAnaMain CheckPeak_tab3
	If(V_value)
		Peak[npnts] = ABS(basefit(XLock[npnts]) - Base[npnts])
	endIf
	
	//Area
	ControlInfo/W=MiniAnaMain CheckArea_tab3
	If(V_value)
		Variable area_a = (basefit(xcsr(C))-basefit(xcsr(A)))/(xcsr(C)-xcsr(A))
		Variable area_b = 0.5*(basefit(xcsr(A))+basefit(xcsr(C))-(xcsr(A)+xcsr(C))*area_a)
		Wave MiniArea0 = root:Packages:MiniAna:MiniArea0
		Wave MiniArea1 = root:Packages:MiniAna:MiniArea1
		MiniArea0 = area_a*x+area_b
		MiniArea1 = basefit - MiniArea0
		AreaUC[npnts] = Area(MiniArea1, xcsr(A), xcsr(C))
	endIf
	
	//Decay
	ControlInfo/W=MiniAnaMain CheckDecay_tab3
	If(V_value)
		CurveFit/Q/NTHR = 0 exp_XOffset basefit(xcsr(B), xcsr(C))
		Wave W_coef
		If(W_coef[2]>0&&W_coef[2]<0.02)
			Decay[npnts] = W_coef[2]
		else
			Decay[npnts] = NaN
		endIf

	endIf
	
	//Rise
	ControlInfo/W=MiniAnaMain CheckRise_tab3
	If(V_value)
		Variable RTXLock0
		Variable RTXLock1
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.1*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock0 = V_LevelX
		FindLevel/Q/R=(xcsr(A), xcsr(B)) basefit, basefit(xcsr(A))+0.9*(basefit(xcsr(B))-basefit(xcsr(A)))
		RTXLock1 = V_LevelX
		If((RTXLock1 - RTXLock0)>0)
			Rise[npnts] = RTXLock1 - RTXLock0
		else
			Rise[npnts] = NaN
		endIf
	endIf
	
	//RecNum
	ControlInfo/W=MiniAnaMain CheckExpRecNum_tab3
	If(V_value)
		RecNum[npnts] = ExpRecNum
	endIf
	
	//Sampling
	ControlInfo/W=MiniAnamain CheckSamplingHz_tab3
	If(V_value)
		Sampling[npnts] = SamplingHz
	endIf
	
	//PCurrent
	ControlInfo/W=MiniAnaMain CheckParentCurrent_tab3
	If(V_value)
		PCurrent[npnts] = SetMiniPCurrent
	endIf
	
	//Error
	ControlInfo/W=MiniAnaMain CheckError_tab3
	If(V_value)
		Error[npnts] = 0
	endIf
	
	//Sorting
//	fldrsav0 = GetDataFolder(1)
//	SetDataFolder root:Packages:MiniAna:
//	String ForSort1 = Wavelist("*", ",", "WIN:MiniAnaTable#T0")
//	String ForSort2 = ForSort1[0, (Strlen(T0WL)-1)]
//	String t = "Sort/A {wvName, XLock, Serial}," + ForSort2
//	Execute t
//	SetDataFolder fldrsav0

	//Serial and IEI
//	FindLevel /Q Serial, 0
//	Variable InsertingPoint = V_LevelX
//	Serial[p,] = x + 1
	
	//IEI and LabelingWave
	ControlInfo/W=MiniAnaMain CheckInterEventInterval_tab3
	If(V_value)
		If(npnts !=0)
			If(StringMatch(wvName[npnts], wvName[npnts-1]))
				IEI[npnts] = XLock[npnts] - XLock[npnts - 1]
				If((XLock[npnts]-XLock[npnts-1])<0.9*IsoCriteria)
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[npnts-1]
					lw1[pcsr(D, "MiniAnaDaughterGraph")] = NaN
					luw1[pcsr(D, "MiniAnaDaughterGraph")] = NaN
					Isolate[npnts-1] = 0
				else
					Cursor/W=MinianaDaughterGraph D $tWaveMini XLock[npnts-1]
					lw1[pcsr(D, "MiniAnaDaughterGraph")] = 1
					luw1[pcsr(D, "MiniAnaDaughterGraph")] = 1
					Isolate[npnts-1] = 1
				endIf
				If(numpnts(Serial) != npnts)
					IEI[npnts+1] = XLock[npnts+1] - XLock[npnts]
					If((XLock[npnts+1]-XLock[npnts])>0.1*IsoCriteria&&(XLock[npnts+2]-XLock[npnts+1])>0.9*IsoCriteria)
						Cursor/W=MinianaDaughterGraph F $tWaveMini XLock[npnts+1]
						lw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
						luw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
						Isolate[npnts+1] = 1
					else
						Cursor/W=MinianaDaughterGraph F $tWaveMini XLock[npnts+1]
//						lw1[pcsr(F, "MiniAnaDaughterGraph")] = 0
//						luw1[pcsr(F, "MiniAnaDaughterGraph")] = 0
						lw1[pcsr(F, "MiniAnaDaughterGraph")] = NaN
						luw1[pcsr(F, "MiniAnaDaughterGraph")] = NaN
						Isolate[npnts+1] = 0
					endIf				
				endIf
			else
				IEI[npnts] = NaN
			endIf
		else
			IEI[npnts] = NaN
			If(numpnts(Serial)>1)
				IEI[npnts+1] = XLock[npnts+1] - XLock[npnts]
				Cursor/W=MinianaDaughterGraph F $tWaveMini XLock[npnts+1]
				lw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
				luw1[pcsr(F, "MiniAnaDaughterGraph")] = 1
				Isolate[npnts+1] = 1
			endIf
		endIf
	endIf
	
	EventSerial = npnts + 1
	Variable point = npnts
	
	EventXLock = XLock[point]
	If(StringMatch(EventWaveName,wvName[point]) == 1)
		EventWaveName = wvName[point]
	else
		RemoveFromGraph/W=MiniAnaEventGraph $EventWaveName
		AppendToGraph/W=MiniAnaEventGraph $wvName[point]
		EventWaveName = wvName[point]
	endIf
	SetAxis/W = MiniAnaEventGraph bottom, (EventXLock-0.3*IsoCriteria), (EventXLock+1.1*IsoCriteria)
	
	Cursor/W=MiniAnaEventGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaEventGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaEventGraph C $wvName[point] xcsr(C)

	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaDaughterGraph C $wvName[point] xcsr(C)
	
//	GetAxis/W = MiniAnaDaughterGraph bottom
//	Variable graphwidth = V_max - V_min
//	SetAxis/W = MiniAnaDaughterGraph bottom, (XLock[point] - 0.2*graphwidth), (XLock[point] + 0.8*graphwidth)

//	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
//	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
//	Cursor/W=MiniAnaDaughterGraph C $wvName[point] XLock[point]+DetectAreaDecayRange

	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	AX = V_min
	RX = V_max - V_min
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	V_max_XD = V_max
	V_min_XD = V_min
	GetAxis/W=MiniAnaDaughterGraph/Q left
	V_max_YD = V_max
	V_min_YD = V_min
	t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)

	ModifyTable/w=MiniAnaTable#T0 selection=(point,0,point,100,0,0)
	
	//Update display
	MiniDispPeak = Peak[point]
	MiniDispArea = AreaUC[point]
	MiniDispRise = Rise[point]
	MiniDispDecay = Decay[point]
	gvError = Error[point]
	
	t_MiniEventLine("")
	
	t_Update_MiniLb2D_Select()
End

Function t_MiniPlaceCsrC(ctrlName) : ButtonControl
	String ctrlName
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	Cursor/W=MiniAnaDaughterGraph  C, $tWaveMini, (xcsr(B) + 0.01)
End

Function t_MiniDaughterSetScale(ctrlName) : ButtonControl
	String ctrlName
	
	NVAR SetMiniTimeInitial = root:Packages:MiniAna:SetMiniTimeInitial
	NVAR SetMiniTimeFinish = root:Packages:MiniAna:SetMiniTimeFinish
	
	Variable key
	key = GetKeyState(0)
	If(key & 4) // Shift key pressed
		SetAxis/W=MiniAnaDaughterGraph bottom, SetMiniTimeInitial, (SetMiniTimeInitial + 0.1)
	else
		SetAxis/W=MiniAnaDaughterGraph bottom, SetMiniTimeInitial, SetMiniTimefinish
	endif
	
	NVAR ScaleMax = root:Packages:MiniAna:MiniAnaScaleMax
	NVAR ScaleMin = root:Packages:MiniAna:MiniAnaScaleMin
	
	SetAxis/W=MiniAnaDaughterGraph left, ScaleMin, ScaleMax
	SetAxis/W=MiniAnaEventGraph bottom, SetMiniTimeInitial, SetMiniTimefinish
	SetAxis/W=MiniAnaEventGraph left, ScaleMin, ScaleMax
	SetAxis/W=MiniAnaParentGraph bottom, SetMiniTimeInitial, SetMiniTimefinish
	SetAxis/W=MiniAnaParentGraph left, (ScaleMin - 0.15*ABS(ScaleMax - ScaleMin)), (ScaleMax + 0.15*ABS(ScaleMax - ScaleMin))
	
End

Function t_MiniLabelWNaN(ctrlName) : ButtonControl
	String ctrlName
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	Wave label0 = $(tWaveMini + "_Label0")
	Wave label1 = $(tWaveMini + "_Label1")
	Wave lw0 = root:Packages:MiniAna:MA_LabelingWave0
	Wave lw1 = root:Packages:MiniAna:MA_LabelingWave1
	label0 = NaN
	label1 = NaN
	lw0 = NaN
	lw1 = NaN
End

Function t_MiniD_PreSweep(ctrlName) : ButtonControl
	String ctrlName
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	Wave/T ListWave = root:Packages:MiniAna:Mini_WaveListWave
	ControlInfo/W=MiniAnaMain MiniWaveList_tab0
	ListBox /Z MiniWaveList_tab0 win=MiniAnaMain, selRow=(V_Value-1), row = (V_Value)
	tWaveMini = ListWave[V_Value-1]
	DoUpdate

	//Display Button
	t_MiniMainDisplay("BtDisplaytWaveMini_tab0")
//	t_MiniDaughterSetScale("BtMiniDSetScale")
//
End

Function t_MiniD_NextSweep(ctrlName) : ButtonControl
	String ctrlName
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	Wave/T ListWave = root:Packages:MiniAna:Mini_WaveListWave
	ControlInfo/W=MiniAnaMain MiniWaveList_tab0
	ListBox /Z MiniWaveList_tab0 win=MiniAnaMain, selRow=(V_Value+1), row = (V_Value)
	tWaveMini = ListWave[V_Value+1]
	DoUpdate

	//Display Button
	t_MiniMainDisplay("BtDisplaytWaveMini_tab0")
//	t_MiniDaughterSetScale("BtMiniDSetScale")
//	t_MiniLabelWNaN("")

End

Function t_MiniEventLine(ctrlName) : ButtonControl
	String ctrlName
	Variable V_max_XD, V_min_XD, V_max_YD, V_min_YD
	Variable V_max_XP, V_min_XP, V_max_YP, V_min_YP
	Variable X0, X1, Y0, Y1
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	Wave XLock = root:Packages:MiniAna:XLock
	Variable Xcord = XLock[EventSerial - 1]
//	Print Xcord
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	V_max_XD = V_max
	V_min_XD = V_min
	GetAxis/W=MiniAnaDaughterGraph/Q left
	V_max_YD = V_max
	V_min_YD = V_min
	
	GetAxis/W=MiniAnaParentGraph/Q bottom
	V_max_XP = V_max
	V_min_XP = V_min
	GetAxis/W=MiniAnaParentGraph/Q left
	V_max_YP = V_max
	V_min_YP = V_min
	X0 = (V_min_XD - V_min_XP)/(V_max_XP - V_min_XP)
	X1 = (V_max_XD - V_min_XP)/(V_max_XP - V_min_XP)
	Y0 = (V_max_YD - V_max_YP)/(V_min_YP - V_max_YP)
	Y1 = (V_min_YD - V_max_YP)/(V_min_YP - V_max_YP)
	DrawAction/W=MiniAnaParentGraph delete
	SetDrawEnv/W=MiniAnaParentGraph fillpat= 0
	DrawRect/W=MiniAnaParentGraph X0, Y0, X1, Y1
	SetDrawEnv/W=MiniAnaParentGraph xcoord= bottom,ycoord= prel,dash= 1
	DrawLine/W=MiniAnaParentGraph Xcord,0,Xcord,1
	
	SetDrawLayer/W=MiniAnaDaughterGraph UserFront
	DrawAction/W=MiniAnaDaughterGraph delete
	SetDrawEnv/W=MiniAnaDaughterGraph xcoord= bottom,ycoord= prel,dash= 1
	DrawLine/W=MiniAnaDaughterGraph Xcord,0,Xcord,1
End

/////////////////////////////////////////////////////////////////////////
//EventGraph
Function t_MiniAnaEventGraph() : Graph
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:MiniAna:
	Display/N=MiniAnaEventGraph/W=(21.75,279.5,291,595.25)/L=MA_LabelAxis0 MA_LabelingWave0
	AppendToGraph/L=MA_LabelAxis1 MA_LabelingWave1
	AppendToGraph Mini_SampleWave
	SetDataFolder fldrSav0
	ModifyGraph margin(left)=57,margin(bottom)=61,margin(top)=85,margin(right)=14,width=198.425
	ModifyGraph height=170.079
	ModifyGraph mode(MA_LabelingWave0)=3,mode(MA_LabelingWave1)=3
	ModifyGraph marker(MA_LabelingWave0)=10,marker(MA_LabelingWave1)=10
	ModifyGraph rgb(MA_LabelingWave1)=(0,0,65280)
	ModifyGraph msize(MA_LabelingWave0)=2,msize(MA_LabelingWave1)=2
	ModifyGraph noLabel(MA_LabelAxis0)=2,noLabel(MA_LabelAxis1)=2
	ModifyGraph lblMargin(bottom)=49
	ModifyGraph axThick(MA_LabelAxis0)=0,axThick(MA_LabelAxis1)=0
	ModifyGraph lblPos(left)=53
	ModifyGraph lblLatPos(bottom)=284
	ModifyGraph freePos(MA_LabelAxis0)=0
	ModifyGraph freePos(MA_LabelAxis1)=0
	ModifyGraph axisEnab(MA_LabelAxis0)={0.9,0.95}
	ModifyGraph axisEnab(MA_LabelAxis1)={0.95,1}
	ModifyGraph axisEnab(left)={0,0.9}
	Label bottom "\\u#2s"
	ShowTools/A
	DefineGuide UGV0={PR,0.644737,GR},UGH0={FB,-93.75},UGV1={FL,11.25}
	NewPanel/W=(0,0.042,1,0.236)/FG=(,FT,,PT)/HOST=#
	TitleBox TitleEventWaveNameLabel,pos={13,13},size={62,12},title="eWaveName"
	TitleBox TitleEventWaveNameLabel,frame=0
	TitleBox TitleEventWaveName,pos={79,11},size={46,20}
	TitleBox TitleEventWaveName,variable= root:Packages:MiniAna:EventWaveName
	SetVariable SetAnaEventSerial,pos={12,33},size={125,16},proc=t_SetEventSerial,title="EventSerial"
	SetVariable SetAnaEventSerial,limits={0,inf,1},value= root:Packages:MiniAna:EventSerial
	SetVariable SetAnaEventXLock,pos={12,51},size={125,16},title="EventXLock"
	SetVariable SetAnaEventXLock,limits={0,inf,0},value= root:Packages:MiniAna:EventXLock,noedit= 1
	Button BtDuplicateEventGraph,pos={13,77},size={70,20},title="Dup&Display"
	ValDisplay valdisp0,pos={142,10},size={20,20},bodyWidth=20,frame=5
	ValDisplay valdisp0,limits={0,1,0},barmisc={0,0},mode= 2,zeroColor= (0,65280,0)
	ValDisplay valdisp0,value= #"root:Packages:MiniAna:gvError"
	SetVariable SetAnaPeak,pos={167,11},size={125,16},title="Peak"
	SetVariable SetAnaPeak,limits={0,inf,0},value= root:Packages:MiniAna:MiniDispPeak,noedit= 1
	SetVariable SetAnaArea,pos={168,29},size={125,16},title="Area"
	SetVariable SetAnaArea,limits={0,inf,0},value= root:Packages:MiniAna:MiniDispArea,noedit= 1
	SetVariable SetAnaRise,pos={167,47},size={125,16},title="Rise"
	SetVariable SetAnaRise,limits={0,inf,0},value= root:Packages:MiniAna:MiniDispRise,noedit= 1
	SetVariable SetAnaDecay,pos={166,65},size={125,16},title="Decay"
	SetVariable SetAnaDecay,limits={0,inf,0},value= root:Packages:MiniAna:MiniDispDecay,noedit= 1
	Button BtMiniRiseNaN,pos={293,42},size={30,20},proc=t_MiniRiseNaN,title="NaN"
	Button BtMiniDecayNaN,pos={293,63},size={30,20},proc=t_MiniDecayNaN,title="NaN"
	Button BtEventIsolateModifyAll,pos={98,67},size={50,20},proc=t_MiniIsoMdAll,title="IsoMdAll"
	Button BtEventComplexModifyAll,pos={98,86},size={50,20},proc=t_MiniCoMdAll,title="CoMdAll"
	RenameWindow #,P0
	SetActiveSubwindow ##
	NewPanel/W=(0.2,0.885,1,0.8)/FG=(FL,,,FB)/HOST=# 
	TitleBox TitleEventIso,pos={149,8},size={40,12},title="Isolated",frame=0
	Button BtEventPreviousIso,pos={95,6},size={18,18},proc=t_BtEventPreNext,title="<"
	Button BtEventNextIso,pos={239,6},size={18,18},proc=t_BtEventPreNext,title=">"
	SetVariable SetAnaEventSerial,pos={114,24},size={125,16},proc=t_SetEventSerial,title="EventSerial"
	SetVariable SetAnaEventSerial,limits={1,inf,1},value= root:Packages:MiniAna:EventSerial
	Button BtEventPrevious,pos={95,23},size={18,18},proc=t_BtEventPreNext,title="<"
	Button BtEventNext,pos={240,23},size={18,18},proc=t_BtEventPreNext,title=">"
	RenameWindow #,P1
	SetActiveSubwindow ##
End

Function t_MiniRiseNaN(ctrlName) : ButtonControl
	String ctrlName
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	Wave Rise = root:Packages:MiniAna:Rise
	Rise[EventSerial - 1] = NaN
	MiniDispRise = NaN
End

Function t_MiniDecayNaN(ctrlName) : ButtonControl
	String ctrlName
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	Wave Decay = root:Packages:MiniAna:Decay
	Decay[EventSerial - 1] = NaN
	MiniDispDecay = NaN
End

Function t_SetEventSerial(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave Isolate = root:Packages:MiniAna:Isolate
	NVAR DetectIsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	EventSerial = varNum
	t_BtEventPreNext("")
//	Variable point = varNum - 1
//	EventWaveName = wvName[point]
//	EventXLock = XLock[point]
//	SetAxis/W = MiniAnaEventGraph bottom, (EventXLock-0.3*DetectIsoCriteria), (EventXLock+1.1*DetectIsoCriteria)
//	t_MiniEventLine("")
End

Function t_BtEventPreNext(ctrlName) : ButtonControl
	String ctrlName
	SVAR tWaveMini = root:Packages:MiniAna:tWaveMini
	SVAR EventWaveName = root:Packages:MiniAna:EventWaveName
	NVAR EventSerial = root:Packages:MiniAna:EventSerial
	NVAR EventXLock = root:Packages:MiniAna:EventXLock
	NVAR DetectIsoCriteria = root:Packages:MiniAna:DetectIsoCriteria
	NVAR gvError = root:Packages:MiniAna:gvError
	NVAR DetectAreaDecayRange = root:Packages:MiniAna:DetectAreaDecayRange
	NVAR MiniDispPeak =  root:Packages:MiniAna:MiniDispPeak
	NVAR MiniDispArea = root:Packages:MiniAna:MiniDispArea
	NVAR MiniDispRise = root:Packages:MiniAna:MiniDispRise
	NVAR MiniDispDecay = root:Packages:MiniAna:MiniDispDecay
	Wave Serial = root:Packages:MiniAna:Serial
	Wave/T wvName = root:Packages:MiniAna:wvName
	Wave XLock = root:Packages:MiniAna:XLock
	Wave ALocked = root:Packages:MiniAna:ALocked
	Wave InitialX = root:Packages:MiniAna:InitialX
	Wave Isolate = root:Packages:MiniAna:Isolate
	Wave Base = root:Packages:MiniAna:Base
	Wave Peak = root:Packages:MiniAna:Peak
	Wave AreaUc = root:Packages:MiniAna:AreaUC
	Wave Decay = root:Packages:MiniAna:Decay
	Wave Rise = root:Packages:MiniAna:Rise
	Wave Error = root:Packages:MiniAna:Error
	Variable AX, RX, V_max_XD, V_min_XD, V_max_YD, V_min_YD
	StrSwitch(ctrlName)
		case "BtEventPreviousIso":
			do
				If((EventSerial >1 && EventSerial < 10000) != 1)
					break
				endIf
				EventSerial -= 1
				If(Isolate[EventSerial-1]  == NaN || Isolate[EventSerial-1]  == 0)
					break
				endIf
			while(1)
			break
		case "BtEventNextIso":
			do
				If((EventSerial < 10000 && EventSerial >= 1) != 1)
					break
				endif
				EventSerial += 1
				If(Isolate[EventSerial-1]  == NaN || Isolate[EventSerial-1]  == 0)
					break
				endIf
			while(1)
			break
		case "MiniDaughterPreviousEvent":
			If(EventSerial ==1)
				break
			endIf
			EventSerial -= 1
			break
		case "BtEventPrevious":
			If(EventSerial ==1)
				break
			endIf
			EventSerial -= 1
			break
		case "MiniDaughterNextEvent":
			EventSerial += 1
			break
		case "BtEventNext":
			EventSerial += 1
			break
		default:
			break
	endSwitch
	Variable point = EventSerial - 1

	//Wave matching 
	If(StringMatch(EventWaveName,wvName[point]) != 1)
		EventWaveName = wvName[point]
		tWaveMini = wvName[point]
		t_MiniMainDisplay("")
	endIf
	
	//MainList selection
	Wave/T ListWave = root:Packages:MiniAna:Mini_WaveListWave
	FindValue/TEXT=tWaveMini ListWave
	ListBox /Z MiniWaveList_tab0 win=MiniAnaMain, selRow=(V_Value), row = (V_Value)
	DoUpdate	
	
	//Event graph set axis
	EventXLock = XLock[point]
	SetAxis/W = MiniAnaEventGraph bottom, (EventXLock-0.3*DetectIsoCriteria), (EventXLock+1.1*DetectIsoCriteria)
	
	//Event graph cursor
	Cursor/W=MiniAnaEventGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaEventGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaEventGraph C $wvName[point] XLock[point]+DetectAreaDecayRange
	
	//Daughter graph set axis
	GetAxis/W = MiniAnaDaughterGraph/Q bottom
	Variable graphwidth = V_max - V_min
	SetAxis/W = MiniAnaDaughterGraph bottom, (XLock[point] - 0.2*graphwidth), (XLock[point] + 0.8*graphwidth)

	//Daughter graph set axis
	Cursor/W=MiniAnaDaughterGraph A $wvName[point] InitialX[point]
	Cursor/W=MiniAnaDaughterGraph B $wvName[point] XLock[point]
	Cursor/W=MiniAnaDaughterGraph C $wvName[point] XLock[point]+DetectAreaDecayRange

	//Parent graph Rect
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	AX = V_min
	RX = V_max - V_min
	GetAxis/W=MiniAnaDaughterGraph/Q bottom
	V_max_XD = V_max
	V_min_XD = V_min
	GetAxis/W=MiniAnaDaughterGraph/Q left
	V_max_YD = V_max
	V_min_YD = V_min
	t_ParentGraphMoveRect(V_max_XD, V_min_XD, V_max_YD, V_min_YD)

	//Table event selection
	ModifyTable/w=MiniAnaTable#T0 selection=(point,0,point,100,0,0)
	
	//Update display
	MiniDispPeak = Peak[point]
	MiniDispArea = AreaUC[point]
	MiniDispRise = Rise[point]
	MiniDispDecay = Decay[point]
	gvError = Error[point]
	
	t_MiniEventLine("")
	
	If(point <8)
		ListBox Lb0, win=MiniAnaTable, row=-1, selRow= point
	else
		ListBox Lb0, win=MiniAnaTable, row=(point - 9), selRow= point
	endif
End

/////////////////////////////////////////////////////////////////////////
//Marquee


