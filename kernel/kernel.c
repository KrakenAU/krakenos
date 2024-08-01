void print_string(const char* str) {
    unsigned char* vidmem = (unsigned char*) 0xb8000;
    unsigned int i = 0;
    while (str[i] != '\0') {
        *vidmem++ = str[i++];
        *vidmem++ = 0x0F; // White text on black background
    }
}

void kernel_main() {
    print_string("Hello World from KrakenOS Kernel!");
    while(1) {} // Add an infinite loop to prevent the CPU from executing random memory
}