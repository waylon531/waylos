//I can't use the test crate so I'm using tests at runtime
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
    
