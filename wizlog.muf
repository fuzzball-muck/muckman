@q
@program wizlog.muf
1 9999 d
i
  
( wizlog.muf    v1.0    Jessy @ FurryMUCK    6/97
  
	Wizlog.muf allows wizards to edit and view a list stored on players.
	It's intended use is for recording administrative information, such
	as warnings about AUP violations.
  
  INSTALLATION:
  
	Port the program and set it Wizard. Link a global action with a 
	name such as @wizlog or wizlog to it. Wizlog.muf requires lib-lmgr
	and a pmatch macro, both of which should be available on any 
	established MUCK.
  
  USAGE:
  
    <cmd> <player> = <entry> .. Make a log entry for <player>
    <cmd> <player> ............ Display log for <player>
		<cmd> #clear <player> ..... Clear log for <player>
  
  
  Wizlog.muf may be freely ported. Please comment any changes.
)
  
(2345678901234567890123456789012345678901234567890123456789012345678901)
 
$include $lib/lmgr
 
$define Tell me @ swap notify $enddef
 
lvar ourArg         (* string: arg passed to command; may be modified *)
lvar ourPlayer                         (* dbref: player we're logging *)

: DoHelp  (  --  )                                (* show help screen *)
  
	" " Tell
	prog name " (#" prog intostr strcat ")" strcat Tell " " Tell

	"The wiz-only " command @ strcat
	" command allows wizards to record and view log entries for "
	"specific players." strcat Tell " " Tell

	"Syntax:" Tell " " Tell

	"  $command <player> = <entry> .... Make a log entry for <player>"
	command @ "$command" subst Tell
	"  $command <player> .............. View log entries for <player>"
	command @ "$command" subst Tell 
	"  $command #clear <player> ....... Clear log for <player>"
	command @ "$command" subst Tell " " Tell
;
 
: DoAddListLine  ( s --  )    (* add a line to @/wizlog# on ourPlayer *)
  
  "@/wizlog" swap over ourPlayer @ 
	LMGR-GetCount 1 + 3 pick ourPlayer @ 
	LMGR-PutElem pop
;
 
: DoShowList  ( d s --  )               (* display list s on object d *)
  
  "@/wizlog" ourPlayer @ LMGR-GetList
	begin
	  dup while
		swap Tell
		1 -
	repeat
	pop
	">>  Done." Tell
;
 
: DoLogEntry  (  --  )       (* add an entry to specifed player's log *)
  
	me @ "W" flag? not if                           (* check permission *)
	  ">>  Permission denied." Tell exit
	then

  ourArg @ dup "=" instr strcut strip ourArg !
	dup if
    strip dup strlen 1 - strcut pop strip
		.pmatch dup if                                     (* find player *)
      dup #-2 dbcmp if
			  ">>  Ambiguous. I'm not sure who you mean." Tell pop exit
			else
			  ourPlayer !
		  then
		else
		  ">>  Player not found." Tell pop exit
		then
                                                      (* format entry *)
		"$me %D : " ourArg @ strcat
		me @ name "$me" subst 
		systime timefmt dup ourArg !
		DoAddListLine                                       (* add to log *)
		">>  " ourArg @ strcat Tell
		">>  Entry created for $player" 
		ourPlayer @ name "$player" subst Tell
	else
    DoHelp exit
	then
;
 
: DoShowLog  (  --  )                (* show log for specified player *)
  
	me @ "W" flag? not if                           (* check permission *)
	  ">>  Permission denied." Tell exit
	then

  ourArg @ strip .pmatch                               (* find player *)
	dup if
    dup #-2 dbcmp if
		  ">>  Ambiguous. I'm not sure who you mean." Tell
		else
		  ourPlayer !                                         (* show log *)
		  ">>  WizLog entries for $player:" 
			ourPlayer @ name "$player" subst Tell
			DoShowList
		then
	else
	  ">>  Player not found." Tell
	then
;
 
: DoClear  ( s --  )                          (* clear log for player *)
  
	me @ "W" flag? not if                           (* check permission *)
	  ">>  Permission denied." Tell exit
  then
                                                       (* find player *)
  ourArg @ dup " " instr strcut swap pop strip .pmatch
	dup if
    dup #-2 dbcmp if
		  ">>  Ambiguous. I'm not sure who you mean." Tell pop exit
		else
		  ourPlayer ! 
		then
	else
	  ">>  Player not found." Tell pop exit
	then
	 
	begin                                           (* get confirmation *)
	  ">>  Please confirm: You wish to clear the wizlog for $player? (y/n)"
		ourPlayer @ name "$player" subst Tell
		read
                                                         (* clear log *)
		"yes" over stringpfx if
		  ourPlayer @ "@/wizlog#/" nextprop
			begin
			  dup while
				ourPlayer @ over nextprop
				ourPlayer @ rot remove_prop
			repeat
			pop
			ourPlayer @ "@/wizlog#" remove_prop
			">>  Log cleared for $player." 
			ourPlayer @ name "$player" subst Tell exit
		else
		  "no" swap stringpfx if
			  ">>  Aborted." Tell exit
			else
			  ">>  Entry not understood." pop
			then
		then
	repeat
;
 
: main
  
	"me" match me !                                 (* make sure I'm me *)
	
	dup if                                           (* parse and route *)
	  ourArg !
	else
	  DoHelp exit
	then

	"#help"  ourArg @ stringpfx if DoHelp  exit then
	ourArg @ dup " " instr strcut pop strip 
	dup if
	  "#clear" swap stringpfx if 
	    DoClear exit 
	  then
  then

	ourArg @ "=" instr if
	  DoLogEntry
	else
	  DoShowLog
	then
;
.
c
q
