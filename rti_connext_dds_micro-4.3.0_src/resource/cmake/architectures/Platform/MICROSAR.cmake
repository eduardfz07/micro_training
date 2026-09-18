###############################################################################
# (c) Copyright, Real-Time Innovations 2023-2023
#
# All rights reserved.
# No duplications, whole or partial, manual or electronic, may be made
# without express written permission.  Any such copies, or
# revisions thereof, must display this notice unaltered.
# This code contains trade secrets of Real-Time Innovations, Inc.
#
################################################################################

INCLUDE(CMakeForceCompiler)
SET(_RTIME_OSAPI_PLATFORM autosar)
SET(RTIME_OSAPI_PLATFORM autosar)

SET(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/platform.tc)

ADD_DEFINITIONS(-D__autosar__)
IF (NOT RTIME_TARGET_NAME MATCHES "^x86_64")
    ADD_DEFINITIONS(-DRTI_32SYSTEM=1)
ENDIF()

SET(RTIME_NO_SHARED_LIB TRUE)
IF (NOT DEFINED RTIME_INCLUDE_AUTOSAR)
    SET(RTIME_INCLUDE_AUTOSAR true)
ENDIF()

SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

IF (DEFINED ENV{OSEK_PATH})
    STRING(REPLACE "\\" "/" USAR_PATH $ENV{OSEK_PATH})
ELSE()
    MESSAGE("Please set the OSEK_PATH environment variable pointing to your SIP. Example:")
    MESSAGE("set OSEK_PATH=C:\\Vector\\CBD2201090_D00")
    MESSAGE(FATAL_ERROR "")
ENDIF()

SET(RTI_BUILD_UNITTESTS_AS_LIBS true CACHE BOOL "" FORCE)
SET(RTIME_EXCLUDE_DT true CACHE BOOL "" FORCE)
SET(RTIME_EXCLUDE_QTS true CACHE BOOL "" FORCE)
SET(RTIME_EXCLUDE_CPP true CACHE BOOL "" FORCE)
SET(RTIME_EXCLUDE_SHMEM true CACHE BOOL "" FORCE)
SET(RTIME_OSAPI_ENABLE_THREAD_SEMAPHORE false CACHE BOOL "" FORCE)

IF (RTIME_TARGET_NAME MATCHES "^(i86|x86_64).*") # Microsar virtual target
    INCLUDE_DIRECTORIES("${USAR_PATH}/BSW/VttOs")
    INCLUDE_DIRECTORIES("${USAR_PATH}/BSW/TcpIp")
    INCLUDE_DIRECTORIES("${USAR_PATH}/BSW/IpBase")
    INCLUDE_DIRECTORIES("${USAR_PATH}/BSW/VStdLib")
    INCLUDE_DIRECTORIES("${USAR_PATH}/BSW/SoAd")
    INCLUDE_DIRECTORIES("${USAR_PATH}/BSW/EthIf")
    INCLUDE_DIRECTORIES("${USAR_PATH}/BSW/VttEth")
    INCLUDE_DIRECTORIES("${USAR_PATH}/BSW/Vtt_Common")
    INCLUDE_DIRECTORIES("${USAR_PATH}/BSW/VttCntrl")
    INCLUDE_DIRECTORIES("${USAR_PATH}/BSW/VttEthTrcv_30_Vtt")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Demo/Appl/Include")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Demo/Appl/GenDataVtt")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Demo/Appl/GenDataVtt/Components")

    SET(_VSTDLIB_CFG_TEMPLATE "${USAR_PATH}/BSW/VStdLib/_VStdLib_Cfg.h")
    IF (NOT EXISTS "${_VSTDLIB_CFG_TEMPLATE}")
        MESSAGE(FATAL_ERROR "Missing MICROSAR VStdLib configuration: ${_VSTDLIB_CFG_TEMPLATE}")
    ENDIF()
    SET(_MICROSAR_GENERATED_INCLUDE_DIR "${CMAKE_BINARY_DIR}/generated/microsar")
    FILE(MAKE_DIRECTORY "${_MICROSAR_GENERATED_INCLUDE_DIR}")
    CONFIGURE_FILE(
        "${_VSTDLIB_CFG_TEMPLATE}"
        "${_MICROSAR_GENERATED_INCLUDE_DIR}/VStdLib_Cfg.h"
        COPYONLY)
    INCLUDE_DIRECTORIES(BEFORE "${_MICROSAR_GENERATED_INCLUDE_DIR}")

    FILE(GLOB _MICROSAR_BSW_DIRS "${USAR_PATH}/BSW/*")
    FOREACH(_bsw_dir ${_MICROSAR_BSW_DIRS})
        IF (IS_DIRECTORY "${_bsw_dir}")
            INCLUDE_DIRECTORIES("${_bsw_dir}")
        ENDIF()
    ENDFOREACH()
    
    SET(RTI_ENDIAN_LITTLE 1)

ELSEIF (RTIME_TARGET_NAME MATCHES "tc29xt.*") # Microsar for TC29x
    INCLUDE_DIRECTORIES("${USAR_PATH}/Components/Os/Implementation")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Components/_Common/Implementation")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Components/TcpIp/Implementation")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Components/IpBase/Implementation")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Components/EthIf/Implementation")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Components/VStdLib/Implementation")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Components/Eth_30_Tricore/Implementation")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Components/EthTrcv_30_Ethmii/Implementation")

    SET(RTI_ENDIAN_LITTLE 1)

ELSEIF (RTIME_TARGET_NAME MATCHES "tc39xt.*") # Microsar for TC39x
    INCLUDE_DIRECTORIES("${USAR_PATH}/Components/_Common/Implementation")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Components/Os/Implementation")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Components/TcpIp/Implementation")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Components/IpBase/Implementation")

    SET(RTI_ENDIAN_LITTLE 1)

ELSEIF (RTIME_TARGET_NAME MATCHES "armv7emleElfghs.*") # Mobilgene (temp)
    INCLUDE_DIRECTORIES("${USAR_PATH}")
    INCLUDE_DIRECTORIES("${USAR_PATH}/stubs")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Os_CYTXXX_R44/common/delivery/inc")
    INCLUDE_DIRECTORIES("${USAR_PATH}/Os_CYTXXX_R44/arch/delivery/inc")
    INCLUDE_DIRECTORIES("${USAR_PATH}/TcpIp_R44/delivery/inc")

    SET(RTI_ENDIAN_LITTLE 1)

ELSE()
    MESSAGE(FATAL_ERROR "No architecture recognized, please select one from: x86/tc29xt/tc39xt")

ENDIF()

SET(RTIME_DDS_ENABLE_FLOW_CONRTOL false)

ADD_DEFINITIONS(-DRTIME_AUTOSAR_MICROSAR)
ADD_DEFINITIONS(-DRTI_AUTOSAR)
ADD_DEFINITIONS(-DOSAPI_DONT_HAVE_REALLOC=1)

SET(RTIME_PLATFORM_PSL
    netiopsl::udp
    ospsl::autosar
)
