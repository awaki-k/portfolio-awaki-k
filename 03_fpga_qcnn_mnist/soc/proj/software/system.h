/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'nios2' in SOPC Builder design 'vga_qcnn_system'
 * SOPC Builder design path: ../../vga_qcnn_system.sopcinfo
 *
 * Generated: Mon Sep 08 08:26:24 JST 2025
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_gen2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x10200820
#define ALT_CPU_CPU_ARCH_NIOS2_R1
#define ALT_CPU_CPU_FREQ 100000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "tiny"
#define ALT_CPU_DATA_ADDR_WIDTH 0x1d
#define ALT_CPU_DCACHE_LINE_SIZE 0
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_DCACHE_SIZE 0
#define ALT_CPU_EXCEPTION_ADDR 0x08000020
#define ALT_CPU_FLASH_ACCELERATOR_LINES 0
#define ALT_CPU_FLASH_ACCELERATOR_LINE_SIZE 0
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 100000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 0
#define ALT_CPU_HARDWARE_MULX_PRESENT 0
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 0
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 0
#define ALT_CPU_ICACHE_SIZE 0
#define ALT_CPU_INST_ADDR_WIDTH 0x1d
#define ALT_CPU_NAME "nios2"
#define ALT_CPU_OCI_VERSION 1
#define ALT_CPU_RESET_ADDR 0x08000000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x10200820
#define NIOS2_CPU_ARCH_NIOS2_R1
#define NIOS2_CPU_FREQ 100000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "tiny"
#define NIOS2_DATA_ADDR_WIDTH 0x1d
#define NIOS2_DCACHE_LINE_SIZE 0
#define NIOS2_DCACHE_LINE_SIZE_LOG2 0
#define NIOS2_DCACHE_SIZE 0
#define NIOS2_EXCEPTION_ADDR 0x08000020
#define NIOS2_FLASH_ACCELERATOR_LINES 0
#define NIOS2_FLASH_ACCELERATOR_LINE_SIZE 0
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 0
#define NIOS2_HARDWARE_MULX_PRESENT 0
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 0
#define NIOS2_ICACHE_LINE_SIZE_LOG2 0
#define NIOS2_ICACHE_SIZE 0
#define NIOS2_INST_ADDR_WIDTH 0x1d
#define NIOS2_OCI_VERSION 1
#define NIOS2_RESET_ADDR 0x08000000


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_NEW_SDRAM_CONTROLLER
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_SYSID_QSYS
#define __ALTERA_AVALON_TIMER
#define __ALTERA_NIOS2_GEN2
#define __ALTERA_UP_AVALON_SRAM
#define __ALTERA_UP_AVALON_VIDEO_PIXEL_BUFFER_DMA
#define __ALTERA_UP_AVALON_VIDEO_RGB_RESAMPLER
#define __ALTPLL
#define __ST2MM_QCNN_IP


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "Cyclone IV E"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart_0"
#define ALT_STDERR_BASE 0x10201098
#define ALT_STDERR_DEV jtag_uart_0
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart_0"
#define ALT_STDIN_BASE 0x10201098
#define ALT_STDIN_DEV jtag_uart_0
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart_0"
#define ALT_STDOUT_BASE 0x10201098
#define ALT_STDOUT_DEV jtag_uart_0
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "vga_qcnn_system"


/*
 * altpll_0 configuration
 *
 */

#define ALTPLL_0_BASE 0x10201060
#define ALTPLL_0_IRQ -1
#define ALTPLL_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ALTPLL_0_NAME "/dev/altpll_0"
#define ALTPLL_0_SPAN 16
#define ALTPLL_0_TYPE "altpll"
#define ALT_MODULE_CLASS_altpll_0 altpll


/*
 * hal configuration
 *
 */

#define ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
#define ALT_MAX_FD 4
#define ALT_SYS_CLK none
#define ALT_TIMESTAMP_CLK none


/*
 * hex0 configuration
 *
 */

#define ALT_MODULE_CLASS_hex0 altera_avalon_pio
#define HEX0_BASE 0x10201040
#define HEX0_BIT_CLEARING_EDGE_REGISTER 0
#define HEX0_BIT_MODIFYING_OUTPUT_REGISTER 0
#define HEX0_CAPTURE 0
#define HEX0_DATA_WIDTH 8
#define HEX0_DO_TEST_BENCH_WIRING 0
#define HEX0_DRIVEN_SIM_VALUE 0
#define HEX0_EDGE_TYPE "NONE"
#define HEX0_FREQ 100000000
#define HEX0_HAS_IN 0
#define HEX0_HAS_OUT 1
#define HEX0_HAS_TRI 0
#define HEX0_IRQ -1
#define HEX0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define HEX0_IRQ_TYPE "NONE"
#define HEX0_NAME "/dev/hex0"
#define HEX0_RESET_VALUE 255
#define HEX0_SPAN 16
#define HEX0_TYPE "altera_avalon_pio"


/*
 * jtag_uart_0 configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart_0 altera_avalon_jtag_uart
#define JTAG_UART_0_BASE 0x10201098
#define JTAG_UART_0_IRQ 0
#define JTAG_UART_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_0_NAME "/dev/jtag_uart_0"
#define JTAG_UART_0_READ_DEPTH 64
#define JTAG_UART_0_READ_THRESHOLD 8
#define JTAG_UART_0_SPAN 8
#define JTAG_UART_0_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_0_WRITE_DEPTH 64
#define JTAG_UART_0_WRITE_THRESHOLD 8


/*
 * sdram configuration
 *
 */

#define ALT_MODULE_CLASS_sdram altera_avalon_new_sdram_controller
#define SDRAM_BASE 0x8000000
#define SDRAM_CAS_LATENCY 3
#define SDRAM_CONTENTS_INFO
#define SDRAM_INIT_NOP_DELAY 0.0
#define SDRAM_INIT_REFRESH_COMMANDS 2
#define SDRAM_IRQ -1
#define SDRAM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDRAM_IS_INITIALIZED 1
#define SDRAM_NAME "/dev/sdram"
#define SDRAM_POWERUP_DELAY 200.0
#define SDRAM_REFRESH_PERIOD 7.8125
#define SDRAM_REGISTER_DATA_IN 1
#define SDRAM_SDRAM_ADDR_WIDTH 0x19
#define SDRAM_SDRAM_BANK_WIDTH 2
#define SDRAM_SDRAM_COL_WIDTH 10
#define SDRAM_SDRAM_DATA_WIDTH 32
#define SDRAM_SDRAM_NUM_BANKS 4
#define SDRAM_SDRAM_NUM_CHIPSELECTS 1
#define SDRAM_SDRAM_ROW_WIDTH 13
#define SDRAM_SHARED_DATA 0
#define SDRAM_SIM_MODEL_BASE 0
#define SDRAM_SPAN 134217728
#define SDRAM_STARVATION_INDICATOR 0
#define SDRAM_TRISTATE_BRIDGE_SLAVE ""
#define SDRAM_TYPE "altera_avalon_new_sdram_controller"
#define SDRAM_T_AC 5.5
#define SDRAM_T_MRD 3
#define SDRAM_T_RCD 20.0
#define SDRAM_T_RFC 70.0
#define SDRAM_T_RP 20.0
#define SDRAM_T_WR 14.0


/*
 * sram_1 configuration
 *
 */

#define ALT_MODULE_CLASS_sram_1 altera_up_avalon_sram
#define SRAM_1_BASE 0x10000000
#define SRAM_1_IRQ -1
#define SRAM_1_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SRAM_1_NAME "/dev/sram_1"
#define SRAM_1_SPAN 2097152
#define SRAM_1_TYPE "altera_up_avalon_sram"


/*
 * st2mm_qcnn_ip_0 configuration
 *
 */

#define ALT_MODULE_CLASS_st2mm_qcnn_ip_0 st2mm_qcnn_ip
#define ST2MM_QCNN_IP_0_BASE 0x10201020
#define ST2MM_QCNN_IP_0_IRQ -1
#define ST2MM_QCNN_IP_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ST2MM_QCNN_IP_0_NAME "/dev/st2mm_qcnn_ip_0"
#define ST2MM_QCNN_IP_0_SPAN 32
#define ST2MM_QCNN_IP_0_TYPE "st2mm_qcnn_ip"


/*
 * sw configuration
 *
 */

#define ALT_MODULE_CLASS_sw altera_avalon_pio
#define SW_BASE 0x10201050
#define SW_BIT_CLEARING_EDGE_REGISTER 0
#define SW_BIT_MODIFYING_OUTPUT_REGISTER 0
#define SW_CAPTURE 0
#define SW_DATA_WIDTH 18
#define SW_DO_TEST_BENCH_WIRING 0
#define SW_DRIVEN_SIM_VALUE 0
#define SW_EDGE_TYPE "NONE"
#define SW_FREQ 100000000
#define SW_HAS_IN 1
#define SW_HAS_OUT 0
#define SW_HAS_TRI 0
#define SW_IRQ -1
#define SW_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SW_IRQ_TYPE "NONE"
#define SW_NAME "/dev/sw"
#define SW_RESET_VALUE 0
#define SW_SPAN 16
#define SW_TYPE "altera_avalon_pio"


/*
 * sysid_qsys_0 configuration
 *
 */

#define ALT_MODULE_CLASS_sysid_qsys_0 altera_avalon_sysid_qsys
#define SYSID_QSYS_0_BASE 0x10201090
#define SYSID_QSYS_0_ID 0
#define SYSID_QSYS_0_IRQ -1
#define SYSID_QSYS_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SYSID_QSYS_0_NAME "/dev/sysid_qsys_0"
#define SYSID_QSYS_0_SPAN 8
#define SYSID_QSYS_0_TIMESTAMP 1757285620
#define SYSID_QSYS_0_TYPE "altera_avalon_sysid_qsys"


/*
 * timer_0 configuration
 *
 */

#define ALT_MODULE_CLASS_timer_0 altera_avalon_timer
#define TIMER_0_ALWAYS_RUN 0
#define TIMER_0_BASE 0x10201000
#define TIMER_0_COUNTER_SIZE 32
#define TIMER_0_FIXED_PERIOD 0
#define TIMER_0_FREQ 100000000
#define TIMER_0_IRQ 1
#define TIMER_0_IRQ_INTERRUPT_CONTROLLER_ID 0
#define TIMER_0_LOAD_VALUE 99999
#define TIMER_0_MULT 0.001
#define TIMER_0_NAME "/dev/timer_0"
#define TIMER_0_PERIOD 1
#define TIMER_0_PERIOD_UNITS "ms"
#define TIMER_0_RESET_OUTPUT 0
#define TIMER_0_SNAPSHOT 1
#define TIMER_0_SPAN 32
#define TIMER_0_TICKS_PER_SEC 1000
#define TIMER_0_TIMEOUT_PULSE_OUTPUT 0
#define TIMER_0_TYPE "altera_avalon_timer"


/*
 * video_pixel_buffer_dma_0 configuration
 *
 */

#define ALT_MODULE_CLASS_video_pixel_buffer_dma_0 altera_up_avalon_video_pixel_buffer_dma
#define VIDEO_PIXEL_BUFFER_DMA_0_BASE 0x10201080
#define VIDEO_PIXEL_BUFFER_DMA_0_IRQ -1
#define VIDEO_PIXEL_BUFFER_DMA_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define VIDEO_PIXEL_BUFFER_DMA_0_NAME "/dev/video_pixel_buffer_dma_0"
#define VIDEO_PIXEL_BUFFER_DMA_0_SPAN 16
#define VIDEO_PIXEL_BUFFER_DMA_0_TYPE "altera_up_avalon_video_pixel_buffer_dma"


/*
 * video_pixel_buffer_dma_1 configuration
 *
 */

#define ALT_MODULE_CLASS_video_pixel_buffer_dma_1 altera_up_avalon_video_pixel_buffer_dma
#define VIDEO_PIXEL_BUFFER_DMA_1_BASE 0x10201070
#define VIDEO_PIXEL_BUFFER_DMA_1_IRQ -1
#define VIDEO_PIXEL_BUFFER_DMA_1_IRQ_INTERRUPT_CONTROLLER_ID -1
#define VIDEO_PIXEL_BUFFER_DMA_1_NAME "/dev/video_pixel_buffer_dma_1"
#define VIDEO_PIXEL_BUFFER_DMA_1_SPAN 16
#define VIDEO_PIXEL_BUFFER_DMA_1_TYPE "altera_up_avalon_video_pixel_buffer_dma"


/*
 * video_rgb_resampler_0 configuration
 *
 */

#define ALT_MODULE_CLASS_video_rgb_resampler_0 altera_up_avalon_video_rgb_resampler
#define VIDEO_RGB_RESAMPLER_0_BASE 0x102010a0
#define VIDEO_RGB_RESAMPLER_0_IRQ -1
#define VIDEO_RGB_RESAMPLER_0_IRQ_INTERRUPT_CONTROLLER_ID -1
#define VIDEO_RGB_RESAMPLER_0_NAME "/dev/video_rgb_resampler_0"
#define VIDEO_RGB_RESAMPLER_0_SPAN 4
#define VIDEO_RGB_RESAMPLER_0_TYPE "altera_up_avalon_video_rgb_resampler"

#endif /* __SYSTEM_H_ */
