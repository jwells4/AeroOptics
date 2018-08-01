#include "Spinnaker.h"
#include "SpinGenApi/SpinnakerGenApi.h"
#include <iostream>
#include <sstream>

using namespace Spinnaker;
using namespace Spinnaker::GenApi;
using namespace Spinnaker::GenICam;
using namespace std;

int RunSingleCamera(CameraPtr pCam)
{
  int result = 0;
  try
    {
      // Retrieve TL device nodemap and print device information
      INodeMap & nodeMapTLDevice = pCam->GetTLDeviceNodeMap();

      result = PrintDeviceInfo(nodeMapTLDevice);

      // Initialize camera
      pCam->Init();

      // Retrieve GenICam nodemap
      INodeMap & nodeMap = pCam->GetNodeMap();

      // Acquire images
      result = result | AcquireImages(pCam, nodeMap, nodeMapTLDevice);

      // Deinitialize camera
      pCam->DeInit();
    }
    
  catch (Spinnaker::Exception &e){
    cout << "Error: " << e.what() << endl;
    result = -1;
  }

  return result;
}
