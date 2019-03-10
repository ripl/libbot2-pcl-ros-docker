FROM ripl/libbot2-ros:latest

# set working directory
ENV WORKDIR "/code"
WORKDIR /code

# define arguments
ARG NCORES=2
ARG VERBOSE=0
ARG PCL_SOURCE_DIR="$WORKDIR/pcl"
ARG PCL_BUILD_DIR="$WORKDIR/pcl-build"
ARG PCL_GIT_REPOSITORY_URL="https://github.com/PointCloudLibrary/pcl.git"
ARG PCL_GIT_REPOSITORY_TAG="pcl-1.8.1"

ARG BUILD_SHARED_LIBS="OFF"
ARG BUILD_TYPE="Release"
ARG CXX_FLAGS="-fPIC -g -fno-omit-frame-pointer -O3 -DNDEBUG"

# input devices support
ARG OPENNI_SUPPORT=0
ARG OPENNI2_SUPPORT=0
ARG REALSENSE_SUPPORT=0

# PCL components
ARG BUILD_PCL_COMMON=1
ARG BUILD_PCL_OCTREE=1
ARG BUILD_PCL_IO=1
ARG BUILD_PCL_KDTREE=1
ARG BUILD_PCL_SEARCH=1
ARG BUILD_PCL_SURFACE=1
ARG BUILD_PCL_SAMPLE_CONSENSUS=1
ARG BUILD_PCL_FILTERS=1
ARG BUILD_PCL_2D=1
ARG BUILD_PCL_FEATURES=1
ARG BUILD_PCL_GEOMETRY=1
ARG BUILD_PCL_VISUALIZATION=1
ARG BUILD_PCL_ML=1
ARG BUILD_PCL_SEGMENTATION=1
ARG BUILD_PCL_KEYPOINTS=1
ARG BUILD_PCL_REGISTRATION=1
ARG BUILD_PCL_OUTOFCORE=1
ARG BUILD_PCL_STEREO=1
ARG BUILD_PCL_TRACKING=1
ARG BUILD_PCL_RECOGNITION=1
ARG BUILD_PCL_TOOLS=1
ARG BUILD_PCL_PEOPLE=1
# ---
ARG BUILD_PCL_GLOBAL_TESTS=0
ARG BUILD_PCL_SIMULATION=0
ARG BUILD_PCL_APPS=0
ARG BUILD_PCL_EXAMPLES=0

# set environment
ENV PCL_INSTALL_DIR "/usr/local"

# install dependencies
RUN apt update \
  && apt install -y \
    software-properties-common \
    build-essential \
    libboost-all-dev \
    libeigen3-dev \
    libflann-dev \
  && rm -rf /var/lib/apt/lists/*

# install support for devices
COPY device_support.step /tmp/device_support.step
RUN \
  OPENNI_SUPPORT=${OPENNI_SUPPORT} \
  OPENNI2_SUPPORT=${OPENNI2_SUPPORT} \
  REALSENSE_SUPPORT=${REALSENSE_SUPPORT} \
  bash /tmp/device_support.step

# retrieve source code, build, install, and clean
RUN git clone \
    --depth 1 \
    -b $PCL_GIT_REPOSITORY_TAG \
    $PCL_GIT_REPOSITORY_URL \
    $PCL_SOURCE_DIR \
  && mkdir -p $PCL_BUILD_DIR \
  && cd $PCL_BUILD_DIR \
  && cmake \
    -DCMAKE_CXX_FLAGS_RELEASE="${CXX_FLAGS}" \
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
    -DCMAKE_INSTALL_PREFIX="${PCL_INSTALL_DIR}" \
    # PCL components
    -DBUILD_common:BOOL=${BUILD_PCL_COMMON} \
    -DBUILD_octree:BOOL=${BUILD_PCL_OCTREE} \
    -DBUILD_io:BOOL=${BUILD_PCL_IO} \
    -DBUILD_kdtree:BOOL=${BUILD_PCL_KDTREE} \
    -DBUILD_search:BOOL=${BUILD_PCL_SEARCH} \
    -DBUILD_surface:BOOL=${BUILD_PCL_SURFACE} \
    -DBUILD_sample_consensus:BOOL=${BUILD_PCL_SAMPLE_CONSENSUS} \
    -DBUILD_filters:BOOL=${BUILD_PCL_FILTERS} \
    -DBUILD_2d:BOOL=${BUILD_PCL_2D} \
    -DBUILD_features:BOOL=${BUILD_PCL_FEATURES} \
    -DBUILD_geometry:BOOL=${BUILD_PCL_GEOMETRY} \
    -DBUILD_visualization:BOOL=${BUILD_PCL_VISUALIZATION} \
    -DBUILD_ml:BOOL=${BUILD_PCL_ML} \
    -DBUILD_segmentation:BOOL=${BUILD_PCL_SEGMENTATION} \
    -DBUILD_keypoints:BOOL=${BUILD_PCL_KEYPOINTS} \
    -DBUILD_registration:BOOL=${BUILD_PCL_REGISTRATION} \
    -DBUILD_outofcore:BOOL=${BUILD_PCL_OUTOFCORE} \
    -DBUILD_stereo:BOOL=${BUILD_PCL_STEREO} \
    -DBUILD_tracking:BOOL=${BUILD_PCL_TRACKING} \
    -DBUILD_recognition:BOOL=${BUILD_PCL_RECOGNITION} \
    -DBUILD_tools:BOOL=${BUILD_PCL_TOOLS} \
    -DBUILD_people:BOOL=${BUILD_PCL_PEOPLE} \
    -DBUILD_global_tests:BOOL=${BUILD_PCL_GLOBAL_TESTS} \
    -DBUILD_simulation:BOOL=${BUILD_PCL_SIMULATION} \
    -DBUILD_apps:BOOL=${BUILD_PCL_APPS} \
    -DBUILD_examples:BOOL=${BUILD_PCL_EXAMPLES} \
    # ---
    $PCL_SOURCE_DIR \
  && make \
    -j${NCORES} \
    VERBOSE=${VERBOSE} \
  && make \
    -j${NCORES} \
    install \
  && cd $WORKDIR \
  && rm -rf $PCL_SOURCE_DIR \
  && rm -rf $PCL_BUILD_DIR
