package pree
//*  Program + Tree = pree

import "core:fmt"
import "core:strings"
import "core:os"
import "core:path/filepath"

CURRENT_DIR: string

Colour :: [3]int

BOLD :: "\x1b[1m"
UNDERLINE :: "\x1b[4m"
BLINK :: "\x1b[5m"
REVERSE :: "\x1b[7m"
HIDE :: "\x1b[8m"
CLEAR :: "\x1b[2J"

@(init)
init :: proc() {
	CURRENT_DIR = os.get_current_directory()
}

RGB_To_ANSI_Code :: proc(colour: Colour, text := true) -> string {
	c := text ? '3' : '4'
	return fmt.aprintf("\x1b[%v8;2;%d;%d;%dm", c, colour.r, colour.g, colour.b)
}

SGR :: enum {
	Reset,
	Bold,
	Faint,
	Italic,
	Underline,
	Slow_Blink,
	Rapid_Blink,
	Invert_Colors,
	Conceal, //* Poor Support
	Strike_Through, //* Not supported by Terminal.app
	Primary_Font,
	Alt_Font_1,
	Alt_Font_2,
	Alt_Font_3,
	Alt_Font_4,
	Alt_Font_5,
	Alt_Font_6,
	Alt_Font_7,
	Alt_Font_8,
	Alt_Font_9,
	Alt_Font_Fraktur,
	Double_Underline,
	Normal_Intensity,
	Neither_Italic_nor_Blackletter,
	Not_Underlined,
	Not_Blinking,
	Porportional_Spacing,
	Not_Invert_Colors,
	Not_Conceal, // !Conceal
	Not_Strikethrough,
	Black_Text = 30,
	Red_Text = 31,
	Green_Text = 32,
	Yellow_Text = 33,
	Blue_Text = 34,
	Magenta_Text = 35,
	Cyan_Text = 36,
	White_Text = 37,
	// use color_rgb
	Default_Text = 39,
	Black_Background = 40,
	Red_Background = 41,
	Green_Background = 42,
	Yellow_Background = 43,
	Blue_Background = 44,
	Magenta_Background = 45,
	Cyan_Background = 46,
	White_Background = 47,
	// use color_rgb
	Default_Background = 49,
	Disable_Proportional_Spacing = 50,
	//
	Bright_Black_Text = 90,
	Bright_Red_Text = 91,
	Bright_Green_Text = 92,
	Bright_Yellow_Text = 93,
	Bright_Blue_Text = 94,
	Bright_Magenta_Text = 95,
	Bright_Cyan_Text = 96,
	Bright_White_Text = 97,
	//
	Bright_Black_Background = 100,
	Bright_Red_Background = 101,
	Bright_Green_Background = 102,
	Bright_Yellow_Background = 103,
	Bright_Blue_Background = 104,
	Bright_Magenta_Background = 105,
	Bright_Cyan_Background = 106,
	Bright_White_Background = 107,
}

set_graphic_rendition :: proc(sgr: SGR) {
	fmt.printf("\x1b[%dm", sgr)
}

depth: int
end :: proc() {
	depth -= 1
}
reset :: proc() {
	fmt.print("\x1b[m")
}
@(deferred_none = end)
start :: proc(loc := #caller_location) {
	indentation: string
	if depth < 0 {
		indentation = strings.repeat("|   ", depth)
	} else {
		indentation = strings.repeat("    ", depth)
	}
	prefix := "|~|"

	location, err := filepath.rel(CURRENT_DIR, loc.file_path)
	line_location: string = fmt.aprintf("(%i:%i)", loc.line, loc.column)
	fmt.print(RGB_To_ANSI_Code(colours[depth % len(colours)], false),RGB_To_ANSI_Code({}))
	fmt.printf(
		"%s%s %s [ %s : %s ]\n",
		indentation,
		prefix,
		loc.procedure,
		location,
		line_location,
	)
	depth += 1
    reset()
}

colours := []Colour{{0, 216, 216}, {255, 160, 122}, {242, 227, 174}}

Message_Type : enum{
    debug,
    warning,
    error,
}

printf :: proc(message_t := Message_Type, message: string, args: ..any) {
    message := fmt.aprintf(message, ..args)
	indentation: string
	if depth == 0 {
		indentation = strings.repeat("|   ", depth)
	} else {
		indentation = strings.repeat("    ", depth)
	}
    prefix := ""

    color : string
    switch message_t{
        case .debug:
            prefix = "|>>"
            color = RGB_To_ANSI_Code(colours[depth-1 % len(colours)])
        case .warning:
            prefix = "|?"
            color = RGB_To_ANSI_Code({255,140,12})
        case .error:
            prefix = "|!"
            color = RGB_To_ANSI_Code({255,0,0})
    }


	// Formatting for the printed line
	lineLength := len(message) + len(indentation) + len(prefix) + 8 // Considering delimiters and additional spaces
	line := strings.repeat("-", lineLength)

	// Split the message by newline character
	lines := strings.split(message, "\n")
	// Print each line with proper indentation and formatting
	for lineText, lineIndex in lines {
        fmt.printf(color)
        
		formattedLine := fmt.aprintf("%s%s %s", indentation, prefix, lineText)
		if lineIndex == len(lines) {
			fmt.printf("%s\n%s\n", formattedLine, line)
		} else {
			fmt.printf("%s\n", formattedLine)
		}
	}
    reset()
}
