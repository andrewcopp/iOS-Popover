//: Playground - noun: a place where people can play

import UIKit

protocol PopoverViewDelegate: class {
    func popoverViewCancel(popoverView: PopoverView)
}

class PopoverView: UIView {
    
    private static let separatorWidth: CGFloat = 1.0
    
    weak var delegate: PopoverViewDelegate?
    
    private let bubbleLayer: CAShapeLayer
    
    var margin: UIEdgeInsets = UIEdgeInsetsMake(16.0, 16.0, 16.0, 16.0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var padding: UIEdgeInsets = UIEdgeInsetsMake(16.0, 16.0, 16.0, 16.0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var cornerRadius: CGFloat = 5.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var confirmationTitle: String? = "Got it" {
        didSet {
            confirmationButton.setTitle(confirmationTitle, forState: .Normal)
            setNeedsLayout()
        }
    }
    
    var confirmationTitleColor: UIColor = UIColor.blueColor() {
        didSet {
            confirmationButton.setTitleColor(confirmationTitleColor, forState: .Normal)
        }
    }
    
    var confirmationFont: UIFont? = UIFont(name: "National-Regular", size: 16.0) {
        didSet{
            confirmationButton.titleLabel?.font = confirmationFont
            setNeedsLayout()
        }
    }
    
    var instructionsText: String? {
        didSet {
            instructionsLabel.text = instructionsText
            setNeedsLayout()
        }
    }
    
    var instructionsTextColor: UIColor = UIColor.blackColor() {
        didSet {
            instructionsLabel.textColor = instructionsTextColor
        }
    }
    
    var instructionsFont: UIFont? = UIFont(name: "National-Regular", size: 16.0) {
        didSet {
            instructionsLabel.font = instructionsFont
            setNeedsLayout()
        }
    }
    
    var maxWidth: CGFloat = 320.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var tailSize: CGSize = CGSize(width: 16.0, height: 16.0) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var tailOffset: CGFloat = 32.0 {
        didSet {
            setNeedsLayout()
        }
    }

    private let instructionsLabel = UILabel()
    private let confirmationButton = UIButton()
    private let separatorView = UIView()
    
    override init(frame: CGRect) {
        
        bubbleLayer = CAShapeLayer()
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
        
        layer.addSublayer(bubbleLayer)
        bubbleLayer.fillColor = UIColor.whiteColor().CGColor
        
        addSubview(instructionsLabel)
        addSubview(confirmationButton)
        addSubview(separatorView)
        
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = instructionsTextColor
        instructionsLabel.font = instructionsLabel.font.fontWithSize(13.0)
        
        confirmationButton.setTitle(confirmationTitle, forState: .Normal)
        confirmationButton.setTitleColor(confirmationTitleColor, forState: .Normal)
        confirmationButton.titleLabel?.font = confirmationButton.titleLabel?.font.fontWithSize(13.0)
        confirmationButton.addTarget(self, action: Selector(confirmationButtonPressed(confirmationButton)), forControlEvents: .TouchUpInside)

        separatorView.backgroundColor = UIColor(white: 221/255.0, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var newFrame = frame
        newFrame.size = intrinsicContentSize()
        frame = newFrame
        
        let minX = CGRectGetMinX(bounds) + margin.left
        let maxX = CGRectGetMaxX(bounds) - margin.right
        
        let minY = CGRectGetMinY(bounds) + margin.top
        let maxY = CGRectGetMaxY(bounds) - margin.bottom
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(minX + cornerRadius, minY))
        path.addLineToPoint(CGPointMake(maxX - cornerRadius, minY))
        path.addArcWithCenter(CGPointMake(maxX - cornerRadius, minY + cornerRadius), radius: cornerRadius, startAngle: CGFloat(3.0 * M_PI_2), endAngle: CGFloat(0.0), clockwise: true)
        path.addLineToPoint(CGPointMake(maxX, maxY - cornerRadius - tailSize.height))
        path.addArcWithCenter(CGPointMake(maxX - cornerRadius, maxY - cornerRadius - tailSize.height), radius: cornerRadius, startAngle: CGFloat(0.0), endAngle: CGFloat(M_PI_2), clockwise: true)
        path.addLineToPoint(CGPointMake(minX + tailOffset + tailSize.width, maxY - tailSize.height))
        path.addLineToPoint(CGPointMake(minX + tailOffset + tailSize.width / 2.0, maxY))
        path.addLineToPoint(CGPointMake(minX + tailOffset, maxY - tailSize.height))
        path.addArcWithCenter(CGPointMake(minX + cornerRadius, maxY - cornerRadius - tailSize.height), radius: cornerRadius, startAngle: CGFloat(M_PI_2), endAngle: CGFloat(M_PI), clockwise: true)
        path.addLineToPoint(CGPointMake(minX, minY + cornerRadius))
        path.addArcWithCenter(CGPointMake(minX + cornerRadius, minY + cornerRadius), radius: cornerRadius, startAngle: CGFloat(M_PI), endAngle: CGFloat(3.0 * M_PI_2), clockwise: true)
        path.closePath()
        
        let confirmationButtonWidth = confirmationButton.intrinsicContentSize().width
        let separatorWidth = self.dynamicType.separatorWidth
        
        confirmationButton.frame = CGRectMake(maxX - confirmationButtonWidth - padding.right, margin.top, confirmationButtonWidth, maxY - minY - tailSize.height)
        instructionsLabel.frame = CGRectMake(minX + padding.left, minY + padding.top, maxX - horizontalMarginsAndPadding() - separatorWidth - confirmationButtonWidth, maxY - minY - verticalInstructionsPadding() - tailSize.height)
        separatorView.frame = CGRectMake(maxX - separatorWidth - confirmationButtonWidth - horizontalConfirmationPadding(), minY + padding.top, separatorWidth, maxY - minY - verticalInstructionsPadding() - tailSize.height)
        
        bubbleLayer.path = path.CGPath
    }
    
    override func intrinsicContentSize() -> CGSize {
        let separatorWidth = self.dynamicType.separatorWidth
        let availableWidth = maxWidth - horizontalMarginsAndPadding() - separatorWidth - confirmationButton.intrinsicContentSize().width
        let instructionsLabelSize = instructionsLabel.sizeThatFits(CGSizeMake(availableWidth, CGFloat.max))
        return CGSize(width: maxWidth, height: verticalMargins() + max(instructionsLabelSize.height + verticalInstructionsPadding(), confirmationButton.intrinsicContentSize().height + verticalConfirmationPadding()) + tailSize.height)
    }
    
    // MARK: Presentation
    
    func presentPopoverFromRect(rect: CGRect, inView view: UIView, animated: Bool) {
        
    }
    
    // MARK: Geometry Helpers
    
    func horizontalMargins() -> CGFloat {
        return margin.left + margin.right
    }
    
    func horizontalInstructionsPadding() -> CGFloat {
        return padding.left + padding.right
    }
    
    func horizontalConfirmationPadding() -> CGFloat {
        return padding.left + padding.right
    }
    
    func horizontalPadding() -> CGFloat {
        return horizontalInstructionsPadding() + horizontalConfirmationPadding()
    }
    
    func horizontalMarginsAndPadding() -> CGFloat {
        return horizontalMargins() + horizontalPadding()
    }
    
    func verticalMargins() -> CGFloat {
        return margin.top + margin.bottom
    }
    
    func verticalInstructionsPadding() -> CGFloat {
        return padding.top + padding.bottom
    }
    
    func verticalConfirmationPadding() -> CGFloat {
        return padding.top + padding.bottom
    }
    
    // MARK: Actions
    
    func confirmationButtonPressed(sender: UIButton) {
        delegate?.popoverViewCancel(self)
    }
    
}

let popoverView = PopoverView(frame: CGRectMake(0.0, 0.0, 320.0, 99.0))
popoverView.instructionsText = "Send a note to begin a convo. When they reply, you can continue chatting in your conversation list."

popoverView.cornerRadius = 10.0

popoverView.intrinsicContentSize()
popoverView.instructionsLabel.frame




