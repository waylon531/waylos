/*  Waylos, a kernel built in rust
    Copyright (C) 2015 Waylon Cude

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
use core::fmt::Write;
use core;
use core::result::Result;
use core::result::Result::Ok;
use core::str::StrExt;
use core::convert::AsMut;
pub static mut SCREEN: Screen = Screen{p: Pos{x: 0, y: 0}};

type VGA = [Char; 80*25];

struct Char {
        pub c: u8,
        pub color: Colour,
}
pub struct Screen {
    pub p: Pos
}
impl Screen {
    pub fn clear(&mut self) {
        let background = Colour::Black;
        for i in 0 .. 80 * 25 {
            unsafe {
                *((0xb8000 + i * 2) as *mut u16) = (background as u16) << 12;
            }
        }
        self.p.reset();
    }
    pub fn new() -> Screen {
        Screen{ p: Pos::new() }
    } 
}
impl Write for Screen {
    fn write_str(&mut self, s: &str) -> Result<(),(core::fmt::Error)> {
        for c in s.chars() { 
            if c != '\n' { //make this check against a list of unprintable characters
                unsafe {
                    let screen = 0xb8000 as *mut VGA;
                    (*screen).as_mut()[self.p.to_number() as usize] = self::Char{c: c as u8, color: Colour::Green};
                }
            }
            if c == '\n' {
                self.p.newline();
            } else {
                self.p.add_char();
            }
        }
        return Ok(());
    }
}


#[derive(Copy,Clone)]
pub struct Pos {
    x: u16,
    y: u16
}
impl Pos {
    fn new() -> Pos {
        Pos{x: 0, y: 0}
    }
    fn to_number(&self) -> u16 {
        self.x + (self.y*80)
    }
    fn newline(&mut self) {
        self.x=0;
        self.y+=1;
    }
    fn add_char(&mut self) {
        self.x+=1;
        if self.x>79 {
            self.newline();
        }
    }
    fn reset(&mut self) {
        self.x=0;
        self.y=0;
    }
}



#[derive(Copy,Clone)]
enum Colour {
    Black      = 0,
    Blue       = 1,
    Green      = 2,
    Cyan       = 3,
    Red        = 4,
    Pink       = 5,
    Brown      = 6,
    LightGray  = 7,
    DarkGray   = 8,
    LightBlue  = 9,
    LightGreen = 10,
    LightCyan  = 11,
    LightRed   = 12,
    LightPink  = 13,
    Yellow     = 14,
    White      = 15,
}
