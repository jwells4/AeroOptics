//==============================================================================
// This class will acquire images from the Point Grey camera buffer.
// Author: Jonathan Wells
// Version: 0.0.1
//==============================================================================

#include "Spinnaker.h"
#include "SpinGenApi/SpinnakerGenApi.h"
#include <iostream>
#include <sstream>

using namespace Spinnaker;
using namespace Spinnaker::GenApi;
using namespace Spinnaker::GenICam;
using namespace std;

// This acquires images continuously and sends them to the fitts tracker and PID modules
int AcquireImages(CameraPtr pCam, INodeMap & nodeMap, INodeMap & nodeMapTLDevice){

  int result = 0;

  cout << "*** IMAGE ACQUISITION ***" << endl;

  try{

    // Retrieve enumeration node from nodemap
    CEnumerationPtr ptrAcquisitionMode = nodeMap.GetNode("AcquisitionMode");

    // Error message if the enumeration node returns a problem
    if (!IsAvailable(ptrAcquisitionMode) || !IsWritable(ptrAcquisitionMode)){
      cout << "Unable to set acquisition mode to continuous (enum retrieval). Aborting..." << endl << endl;
      return -1;
    }

    // Retrieve entry node from enumeration node.  Setting acquisition mode to continuous.
    CEnumEntryPtr ptrAcquisitionModeContinuous = ptrAcquisitionMode->GetEntryByName("Continuous");

    // Error message if entry node returns a problem
    if (!IsAvailable(ptrAcquisitionModeContinuous) || !IsReadable(ptrAcquisitionModeContinuous)){
      cout << "Unable to set acquisition mode to continuous (entry retrieval). Aborting..." << endl << endl;
      return -1;
    }

    // Retrieve integer value from entry node
    int64_t acquisitionModeContinuous = ptrAcquisitionModeContinuous->GetValue();

    // Set integer value from entry node as new value of enumeration node
    ptrAcquisitionMode->SetIntValue(acquisitionModeContinuous);

    cout << "Acquisition mode set to continuous..." << endl;

    pCam->BeginAcquisition();
    cout << "Acquiring Images..." << endl;

    // Create a loop that is infinite while the system is in "RUN".
    bool runStatus = true;

    while (runStatus == true){
      try{
        // Retrieve next image and ensure image completion
        ImagePtr pResultImage = pCam->GetNextImage();
        if (pResultImage->IsIncomplete()){
          cout << "Image incomplete with image status " << pResultImage->GetImageStatus() << "..." << endl << endl;
        }
        // Release current image
        pResultImage->Release();
      }
    }

    // End acquisition
    pCam->EndAcquisition();

  }

  return result;

}
