
#import "DALinedTextView.h"

#define DEFAULT_HORIZONTAL_COLOR    [UIColor colorWithRed:0.722f green:0.910f blue:0.980f alpha:0.9f]
#define DEFAULT_VERTICAL_COLOR      [UIColor colorWithRed:0.957f green:0.416f blue:0.365f alpha:0.9f]
#define DEFAULT_MARGINS             UIEdgeInsetsMake(5.0f, 10.0f, 10.0f, 10.0f)

@interface DALinedTextView ()

@property (nonatomic, assign) UIView *webDocumentView;

@end

@implementation DALinedTextView

+ (void)initialize
{
    if (self == [DALinedTextView class])
    {
        id appearance = [self appearance];
        [appearance setContentMode:UIViewContentModeRedraw];
        [appearance setHorizontalLineColor:DEFAULT_HORIZONTAL_COLOR];
        [appearance setVerticalLineColor:DEFAULT_VERTICAL_COLOR];
        [appearance setMargins:DEFAULT_MARGINS];
    }
}

#pragma mark - Superclass overrides

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Recycling the font is necessary
        // For proper line/text alignment
        UIFont *font = self.font;
        self.font = nil;
        self.font = font;
                
        // We need to grab the underlying webView
        // And resize it along with the margins
        self.webDocumentView = [self.subviews objectAtIndex:0];
        self.margins = [self.class.appearance margins];
    }
    return self;
}

- (void)setContentSize:(CGSize)contentSize
{
    contentSize = (CGSize) {
        .width = contentSize.width - self.margins.left - self.margins.right,
        .height = MAX(contentSize.height, self.bounds.size.height - self.margins.top)
    };
    self.webDocumentView.frame = (CGRect) {
        .origin = self.webDocumentView.frame.origin,
        .size = contentSize
    };
    [super setContentSize:contentSize];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5f);
    
    if (self.horizontalLineColor)
    {
        CGContextBeginPath(context);
        CGContextSetStrokeColorWithColor(context, self.horizontalLineColor.CGColor);
        
        // Create un-mutated floats outside of the for loop.
        // Reduces memory access.
        CGFloat baseOffset = 7.0f + self.font.descender;
//        CGFloat screenScale = [UIScreen mainScreen].scale;
        CGFloat boundsX = self.bounds.origin.x;
        CGFloat boundsWidth = self.bounds.size.width;
        
        // Only draw lines that are visible on the screen.
        // (As opposed to throughout the entire view's contents)
        NSInteger firstVisibleLine = MAX(1, (self.contentOffset.y / self.font.lineHeight));
        NSInteger lastVisibleLine = ceilf((self.contentOffset.y + self.bounds.size.height) / self.font.lineHeight);
//        for (NSInteger line = firstVisibleLine; line <= lastVisibleLine; ++line)
//        {
//            CGFloat linePointY = (baseOffset + (self.font.lineHeight * line));
//            // Rounding the point to the nearest pixel.
//            // Greatly reduces drawing time.
//            CGFloat roundedLinePointY = roundf(linePointY * screenScale) / screenScale;
//            CGContextMoveToPoint(context, boundsX, roundedLinePointY);
//            CGContextAddLineToPoint(context, boundsWidth, roundedLinePointY);
//        }
        
        for (NSInteger line = firstVisibleLine; line <= lastVisibleLine; ++line)
        {
            CGFloat linePointY = (baseOffset + ((self.font.lineHeight + 1.0f) * (float)line))+1;
            CGContextMoveToPoint(context, boundsX, linePointY);
            CGContextAddLineToPoint(context, boundsWidth, linePointY);
        }

        
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
    
    if (self.verticalLineColor)
    {
        CGContextBeginPath(context);
        CGContextSetStrokeColorWithColor(context, self.verticalLineColor.CGColor);
        CGContextMoveToPoint(context, -1.0f, self.contentOffset.y);
        CGContextAddLineToPoint(context, -1.0f, self.contentOffset.y + self.bounds.size.height);
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setNeedsDisplay];
}

#pragma mark - Property methods

- (void)setHorizontalLineColor:(UIColor *)horizontalLineColor
{
    _horizontalLineColor = horizontalLineColor;
    [self setNeedsDisplay];
}

- (void)setVerticalLineColor:(UIColor *)verticalLineColor
{
    _verticalLineColor = verticalLineColor;
    [self setNeedsDisplay];
}

- (void)setMargins:(UIEdgeInsets)margins
{
    _margins = margins;
    self.contentInset = (UIEdgeInsets) {
        .top = self.margins.top,
        .left = self.margins.left,
        .bottom = self.margins.bottom,
        .right = self.margins.right - self.margins.left
    };
    [self setContentSize:self.contentSize];
}

@end