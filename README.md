READMENot enough direct memory.  

Please adjust -XX:MaxDirectMemorySize, druid.processing.buffer.sizeBytes, 

or druid.processing.numThreads:



 maxDirectMemory[238,551,040], memoryNeeded[2,147,483,648] = druid.processing.buffer.sizeBytes[1,073,741,824] * ( druid.processing.numThreads[1] + 1 )