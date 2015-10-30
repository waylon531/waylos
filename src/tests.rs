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
//I can't use the test crate so I'm using tests at runtime
//It probably would have been better to make an external testing crate
use screen::Screen;
use hydrogen;
use core::fmt::Write;
#[cfg(feature = "test")]
pub fn test(screen: &mut Screen) {
    write!(screen,"Testing mmap\n");
    write!(screen,"Test 1 = {}\n",hydrogen::mmap_info{address: 0, length: 30, available: 1, padding: 0}.contains(0,20));
    write!(screen,"Test 2 = {}\n",!hydrogen::mmap_info{address: 0, length: 30, available: 1, padding: 0}.contains(0,31));
    write!(screen,"Test 3 = {}\n",!hydrogen::mmap_info{address: 0, length: 30, available: 2, padding: 0}.contains(0,20));
    write!(screen,"Test 4 = {}\n",!hydrogen::mmap_info{address: 0, length: 30, available: 1, padding: 0}.contains(11,20));
    write!(screen,"Test 5 = {}\n",hydrogen::mmap_info{address: 0, length: 30, available: 1, padding: 0}.contains(10,20));
}
#[cfg(not(feature = "test"))]
pub fn test(screen: &mut Screen) {

}
    
