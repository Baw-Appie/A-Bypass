// #import "ABPattern.m"

// #define MSHookFunction DobbyHook
#define ABPattern AppIePattern

#define getIvar(object, ivar) [object valueForKey:ivar]
#define setIvar(object, ivar, value) [object setValue:value forKey:ivar]

#define objcInvokeT(a, b, t) ((t (*)(id, SEL))objc_msgSend)(a, NSSelectorFromString(b))
#define objcInvoke(a, b) objcInvokeT(a, b, id)
#define objcInvoke_1(a, b, c) ((id (*)(id, SEL, typeof(c)))objc_msgSend)(a, NSSelectorFromString(b), c)
#define objcInvoke_2(a, b, c, d) ((id (*)(id, SEL, typeof(c), typeof(d)))objc_msgSend)(a, NSSelectorFromString(b), c, d)
#define objcInvoke_3(a, b, c, d, e) ((id (*)(id, SEL, typeof(c), typeof(d), typeof(e)))objc_msgSend)(a, NSSelectorFromString(b), c, d, e)

#define assertGotExpectedObject(obj, type) if (!obj || ![obj isKindOfClass:NSClassFromString(type)]) [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", type, obj]

@interface AppIePattern : NSObject {
    NSMutableArray *k;
    NSMutableDictionary *m;
    NSMutableArray *p;
    NSMutableArray *z;
    NSMutableArray *u;
    NSMutableDictionary *I;
    NSMutableDictionary *o;
}
@property (nonatomic) BOOL a;
@property (nonatomic, retain) NSNumber *b;
@property (nonatomic, copy) NSMutableArray *d;
@property (nonatomic, retain) NSMutableArray *e;
@property (nonatomic, copy) NSMutableArray *f;
@property (nonatomic, copy) NSArray *ABASMBlackList;
@property (nonatomic, copy) NSArray *hookSVC80;
@property (nonatomic, copy) NSArray *noHookingPlz;
@property (nonatomic, copy) NSArray *enforceDYLD;
@property (nonatomic, copy) NSArray *aaaa;
+ (instancetype)sharedInstance;
- (NSArray *)pattern;
-(void)usk:(NSString *)oldpath n:(NSString *)newpath;
-(BOOL)i:(NSString *)path;
-(BOOL)u:(NSString *)path i:(int)index;
- (NSString *)re:(NSString *)path;
-(BOOL)c:(NSString *)path;
-(BOOL)k:(NSString *)path;
-(void)setup:(NSArray *)array;
-(NSError *)er;
-(BOOL)ozd:(NSString *)name;
@end


@interface ABPatternObject : NSObject
@property (nonatomic, retain) id dummy;
@end



struct STS1 {
    unsigned char uv[16];
    id il;
    unsigned char uq[12];
    struct STS2 *pSTS2;
};

struct STS2 {
    unsigned char iu[16];
    const struct mach_header *lo;
    unsigned char we[7];
    id il;
    struct STS3 *nb;
    unsigned char uh[30];
    unsigned char uq[30];
    unsigned char sd[30];
    unsigned char ur;
    unsigned char op;
    unsigned char mv;
    unsigned char ao;
    unsigned char ei;
    unsigned char wz;
    unsigned char vu[7];
};

struct STS3 {
    unsigned char po[16];
    id pu;
    unsigned char pa[9];
    id px;
    unsigned char pb[7];
    id pz;
    unsigned char pm[7];
    id pl;
    id pv;
    id ps;
    id pi;
    id pc;
};