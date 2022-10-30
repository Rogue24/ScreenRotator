//
//  RotatorView.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import SwiftUI

struct RotatorView: View {
    @StateObject var viewState: RotatorViewState
    @StateObject var srState = ScreenRotatorState()
    
    var body: some View {
        VStack(spacing: 10) {
            ToggleOrientationButton(orientation: $srState.orientation)
                .showStyle(isShow: viewState.isShow)
            
            HStack(spacing: 10) {
                Group {
                    OrientationButton(tag: .landscapeLeft,
                                      orientation: $srState.orientation)
                    OrientationButton(tag: .portrait,
                                      orientation: $srState.orientation)
                    OrientationButton(tag: .landscapeRight,
                                      orientation: $srState.orientation)
                }
                .showStyle(isShow: viewState.isShow)
            }
            
            HStack(spacing: 10) {
                Group {
                    LockOrientationButton(isLock: $srState.isLockOrientation)
                    LockLandscapeButton(isLock: $srState.isLockLandscape)
                }
                .showStyle(isShow: viewState.isShow)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Button() {
                viewState.hide?()
            } label: {
                Color.clear
            }
        )
    }
}

// MARK: - Button
struct ToggleOrientationButton: View {
    @Binding var orientation: ScreenRotator.Orientation
    
    var body: some View {
        Button {
            ScreenRotator.shared.toggleOrientation()
        } label: {
            Image("screen_toggle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 65, height: 65)
                .rotation3DEffect(.degrees(orientation == .portrait ? 0 : -90), axis: (x: 0, y: 0, z: 1))
                .animation(.linear(duration: 0.3), value: orientation == .portrait)
                .frame(width: 100, height: 100)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct OrientationButton: View {
    let tag: ScreenRotator.Orientation
    @Binding var orientation: ScreenRotator.Orientation
    
    var body: some View {
        Button {
            orientation = tag
        } label: {
            Image(systemName: tag == .portrait ? "iphone" : "iphone.landscape")
                .font(.system(size: 50))
                .animatableForegroundColor(from: .secondaryLabel, to: .label, progress: orientation == tag ? 1 : 0)
                .animation(.linear(duration: 0.3), value: orientation == tag)
                .rotation3DEffect(.degrees(orientation == .landscapeRight ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .frame(width: 100, height: 100)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct LockOrientationButton: View {
    @Binding var isLock: Bool
    
    var body: some View {
        Button {
            isLock.toggle()
        } label: {
            Image(systemName: isLock ? "lock.rotation" : "lock.rotation.open")
                .font(.system(size: 50))
                .animatableForegroundColor(from: .secondaryLabel, to: .label, progress: isLock ? 1 : 0)
                .animation(.linear(duration: 0.2), value: isLock)
                .frame(width: 100, height: 100)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct LockLandscapeButton: View {
    @Binding var isLock: Bool
    
    var body: some View {
        Button {
            isLock.toggle()
        } label: {
            ZStack {
                Image(systemName: "iphone.landscape")
                    .font(.system(size: 50))
                Image(systemName: isLock ? "lock" : "lock.open")
                    .font(.system(size: 12).weight(.bold))
                    .offset(y: -0.5)
            }
            .animatableForegroundColor(from: .secondaryLabel, to: .label, progress: isLock ? 1 : 0)
            .animation(.linear(duration: 0.2), value: isLock)
            .frame(width: 100, height: 100)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
//            .opacity(configuration.isPressed ? 0.6 : 1)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.55,
                               dampingFraction: 0.45,
                               blendDuration: 0).speed(2), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct RotatorView_Previews: PreviewProvider {
    static var previews: some View {
        RotatorView(viewState: .init(isShow: true, hide: nil))
            .background(.ultraThinMaterial)
            .background(
                Image(uiImage: UIImage(contentsOfFile: Bundle.main.path(forResource: "IMG_6352", ofType: "jpg")!)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
            .previewDevice("iPhone 11")
    }
}


