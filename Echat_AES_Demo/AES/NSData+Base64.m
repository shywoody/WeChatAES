//
//  NSData+Base64.h
//  Gurpartap Singh
//
//  Created by Gurpartap Singh on 06/05/12.
//  Copyright (c) 2012 Gurpartap Singh. All rights reserved.
//

#import "NSData+Base64.h"

@implementation NSData (Base64Additions)

+ (NSData *)base64DataFromString:(NSString *)string {
  unsigned long ixtext, lentext;
  unsigned char ch, inbuf[4], outbuf[3];
  short i, ixinbuf;
  Boolean flignore, flendtext = false;
  const unsigned char *tempcstring;
  NSMutableData *theData;
  
  if (string == nil) {
    return [NSData data];
  }
  
  ixtext = 0;
  
  tempcstring = (const unsigned char *)[string UTF8String];
  
  lentext = [string length];
  
  theData = [NSMutableData dataWithCapacity: lentext];
  
  ixinbuf = 0;
  
  while (true) {
    if (ixtext >= lentext) {
      break;
    }
    
    ch = tempcstring [ixtext++];
    
    flignore = false;
    
    if ((ch >= 'A') && (ch <= 'Z')) {
      ch = ch - 'A';
    }
    else if ((ch >= 'a') && (ch <= 'z')) {
      ch = ch - 'a' + 26;
    }
    else if ((ch >= '0') && (ch <= '9')) {
      ch = ch - '0' + 52;
    }
    else if (ch == '+') {
      ch = 62;
    }
    else if (ch == '=') {
      flendtext = true;
    }
    else if (ch == '/') {
      ch = 63;
    }
    else {
      flignore = true; 
    }
    
    if (!flignore) {
      short ctcharsinbuf = 3;
      Boolean flbreak = false;
      
      if (flendtext) {
        if (ixinbuf == 0) {
          break;
        }
        
        if ((ixinbuf == 1) || (ixinbuf == 2)) {
          ctcharsinbuf = 1;
        }
        else {
          ctcharsinbuf = 2;
        }
        
        ixinbuf = 3;
        
        flbreak = true;
      }
      
      inbuf [ixinbuf++] = ch;
      
      if (ixinbuf == 4) {
        ixinbuf = 0;
        
        outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
        outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
        outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
        
        for (i = 0; i < ctcharsinbuf; i++) {
          [theData appendBytes: &outbuf[i] length: 1];
        }
      }
      
      if (flbreak) {
        break;
      }
    }
  }
  
  return theData;
}

- (NSString *)utf8String {
    NSString *string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    if (string == nil) {
        string = [[NSString alloc] initWithData:[self UTF8Data] encoding:NSUTF8StringEncoding];
    }
    return string;
}

//              https://zh.wikipedia.org/wiki/UTF-8
//              https://www.w3.org/International/questions/qa-forms-utf-8
//
//            $field =~
//                    m/\A(
//            [\x09\x0A\x0D\x20-\x7E]            # ASCII
//            | [\xC2-\xDF][\x80-\xBF]             # non-overlong 2-byte
//            |  \xE0[\xA0-\xBF][\x80-\xBF]        # excluding overlongs
//            | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}  # straight 3-byte
//            |  \xED[\x80-\x9F][\x80-\xBF]        # excluding surrogates
//            |  \xF0[\x90-\xBF][\x80-\xBF]{2}     # planes 1-3
//            | [\xF1-\xF3][\x80-\xBF]{3}          # planes 4-15
//            |  \xF4[\x80-\x8F][\x80-\xBF]{2}     # plane 16
//            )*\z/x;

- (NSData *)UTF8Data {
    //保存结果
    NSMutableData *resData = [[NSMutableData alloc] initWithCapacity:self.length];
    
    NSData *replacement = [@"�" dataUsingEncoding:NSUTF8StringEncoding];
    
    uint64_t index = 0;
    const uint8_t *bytes = self.bytes;
    
    long dataLength = (long) self.length;
    
    while (index < dataLength) {
        uint8_t len = 0;
        uint8_t firstChar = bytes[index];
        
        // 1个字节
        if ((firstChar & 0x80) == 0 && (firstChar == 0x09 || firstChar == 0x0A || firstChar == 0x0D || (0x20 <= firstChar && firstChar <= 0x7E))) {
            len = 1;
        }
        // 2字节
        else if ((firstChar & 0xE0) == 0xC0 && (0xC2 <= firstChar && firstChar <= 0xDF)) {
            if (index + 1 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                if (0x80 <= secondChar && secondChar <= 0xBF) {
                    len = 2;
                }
            }
        }
        // 3字节
        else if ((firstChar & 0xF0) == 0xE0) {
            if (index + 2 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                uint8_t thirdChar = bytes[index + 2];
                
                if (firstChar == 0xE0 && (0xA0 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                } else if (((0xE1 <= firstChar && firstChar <= 0xEC) || firstChar == 0xEE || firstChar == 0xEF) && (0x80 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                } else if (firstChar == 0xED && (0x80 <= secondChar && secondChar <= 0x9F) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                }
            }
        }
        // 4字节
        else if ((firstChar & 0xF8) == 0xF0) {
            if (index + 3 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                uint8_t thirdChar = bytes[index + 2];
                uint8_t fourthChar = bytes[index + 3];
                
                if (firstChar == 0xF0) {
                    if ((0x90 <= secondChar & secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                } else if ((0xF1 <= firstChar && firstChar <= 0xF3)) {
                    if ((0x80 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                } else if (firstChar == 0xF3) {
                    if ((0x80 <= secondChar && secondChar <= 0x8F) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                }
            }
        }
        // 5个字节
        else if ((firstChar & 0xFC) == 0xF8) {
            len = 0;
        }
        // 6个字节
        else if ((firstChar & 0xFE) == 0xFC) {
            len = 0;
        }
        
        if (len == 0) {
            index++;
            [resData appendData:replacement];
        } else {
            [resData appendBytes:bytes + index length:len];
            index += len;
        }
    }
    
    return resData;
}



@end
