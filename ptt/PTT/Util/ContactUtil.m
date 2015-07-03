//
//  ContactUtil.m
//  PTT
//
//  Created by xihan on 15/6/15.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "ContactUtil.h"
#import <AddressBook/AddressBook.h>
#import "NSString+Extension.h"

@implementation ContactUtil


+ (NSMutableArray *) getContacts
{
    ABAddressBookRef addressBook;
    NSMutableArray *addressBookTemp = [NSMutableArray array];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
         addressBook =  ABAddressBookCreateWithOptions(NULL, NULL);
        
        //获取通讯录权限
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){dispatch_semaphore_signal(sema);});
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
       // dispatch_release(sema);
    }
    
    //获取通讯录中的所有人
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    //循环，获取每个人的个人信息
    for (NSInteger i = 0; i < nPeople; i++)
    {
        //获取个人
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
     
        //获取个人名字
        CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFStringRef abFullName = ABRecordCopyCompositeName(person);
        NSString *nameString = (__bridge NSString *)abName;
        NSString *lastNameString = (__bridge NSString *)abLastName;
        
        if ((__bridge id)abFullName != nil) {
            nameString = (__bridge NSString *)abFullName;
        } else {
            if ((__bridge id)abLastName != nil)
            {
                nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
            }
        }

        
        ABPropertyID multiProperties[] = {
            kABPersonPhoneProperty,
        };
        
        
        NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
        for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
            ABPropertyID property = multiProperties[j];
            ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
            NSInteger valuesCount = 0;
            if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
            
            if (valuesCount == 0) {
                CFRelease(valuesRef);
                continue;
            }
            //获取电话号码和email
            for (NSInteger k = 0; k < valuesCount; k++) {
                CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                CFTypeRef valueLabel = ABAddressBookCopyLocalizedLabel( ABMultiValueCopyLabelAtIndex(valuesRef, k));
                switch (j) {
                    case 0: {
                        NSString *num = (__bridge NSString*)value;
                        NSString *num2 = [ContactUtil handlePhoneNumber:num];
                        if (num2 != nil  && nameString != nil ) {
                           NSDictionary *dic = @{@"name":nameString, @"num":num2 };
                             [addressBookTemp addObject:dic];
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
                CFRelease(value);
                CFRelease(valueLabel);
            }
            CFRelease(valuesRef);
        }

        if (abName) CFRelease(abName);
        if (abLastName) CFRelease(abLastName);
        if (abFullName) CFRelease(abFullName);
    }
    return addressBookTemp;
}

+ (NSString *)handlePhoneNumber:(NSString *)phone{
    if (phone == nil) {
        return nil;
    }
    phone = [ContactUtil deleteString:@"-" fromOriginString:phone];
    if ([phone isMobileNumber]) {
        return phone;
    }
    return nil;
}

+ (NSString *)deleteString:(NSString *)deleteStr fromOriginString:(NSString *)oriStr{
    while (1) {
        NSRange range = [oriStr rangeOfString:deleteStr];
        if (NSNotFound == range.location) {
            break;
        }
        oriStr = [NSString stringWithFormat:@"%@%@",[oriStr substringToIndex:range.location], [oriStr substringFromIndex:(range.location+1)]];
    }
    return oriStr;
}

@end
