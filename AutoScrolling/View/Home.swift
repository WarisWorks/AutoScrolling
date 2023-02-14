//
//  Home.swift
//  AutoScrolling
//
//  Created by Waris on 2023/02/14.
//

import SwiftUI

struct Home: View {
    //MARK: View Properties
    @State private var activeTab: ProductType = .iphone
    @Namespace private var animation
    @State private var productsBasedOnType: [[Product]] = []
    @State private var animationProgress: CGFloat = 0

    var body: some View {
        //MARK: For Auto Scrolling
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
               //MARK: Lazy Stack For Pinning View At Top While Scrolling
                LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]){
                    Section {
                        ForEach(productsBasedOnType, id: \.self) { products in
                            ProductSectionView(products)
                        }
                    } header: {
                        ScrollableTabs(proxy)
                    }
                }
            }
        }
        //MARK: For scroll Content offset Detection
        .coordinateSpace(name: "CONTENTVIEW")
        .navigationTitle("Apple Store")
        //MARK: Custom NavBar Background
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color("Blue"), for: .navigationBar)
        //Dark Scheme For NavBar
        .toolbarColorScheme(.dark, for: .navigationBar)
        .background{
            Rectangle()
                .fill(Color("BG"))
                .ignoresSafeArea()
        }
        .onAppear{
            //Filtering Products Based on Product type
            guard productsBasedOnType.isEmpty else { return }
            
            for type in ProductType.allCases{
                let products = products.filter { $0.type == type }
                productsBasedOnType.append(products)
            }
            
        }
    }
    
    //MARK: Products sectioned view
    @ViewBuilder
    func ProductSectionView(_ products: [Product]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            //MARK: Safe Check
            if let firstProduct = products.first {
                Text(firstProduct.type.rawValue)
                    .font(.title)
                    .fontWeight(.semibold)
            }
            
            ForEach(products){ product in
                ProductRowView(product)
            }
        }
        .padding(15)
        //MARK: For auto scrolling
        .id(products.type)
        .offset("CONTENTVIEW") { rect in
            let minY = rect.minY
            if (minY < 30 && -minY < (rect.midY / 2) && activeTab != products.type)  && animationProgress == 0 {
                withAnimation(.easeInOut(duration: 0.3)){
                    //MARK: Safetey check
                    activeTab = (minY < 30 && -minY < (rect.midY / 2) && activeTab != products.type) ? products.type : activeTab
                }
            }
        }
    }
    
    //MARK: Product Row View
    @ViewBuilder
    func ProductRowView(_ product: Product) -> some View {
        HStack(spacing: 15){
            Image(product.productImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(10)
                .background{
                    RoundedRectangle(cornerRadius: 15,style: .continuous)
                        .fill(.white)
                }
            
            VStack(alignment: .leading,spacing: 8) {
                Text(product.title)
                    .font(.title3)
                
                Text(product.subtitle)
                    .font(.callout)
                    .foregroundColor(.gray)
                
                Text(product.price)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("Blue"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading )
    }
    
    //MARK: Scrollable Tabs
    @ViewBuilder
    func ScrollableTabs(_ proxy: ScrollViewProxy)-> some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10){
                ForEach(ProductType.allCases, id: \.rawValue){ type in
                    Text(type.rawValue)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    //MARK: Active tab indicator
                        .background(alignment: .bottom, content: {
                            if activeTab == type {
                                Capsule()
                                    .fill(.white)
                                    .frame(height: 5)
                                    .padding(.horizontal, -5)
                                    .offset(y: 15)
                                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                            }
                        })
                        .padding(.horizontal, 15)
                        .contentShape(Rectangle())
                    //MARK: Scrolling tab's when ever the active tab is updated
                        .id(type.tabID)
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.3)){
                                activeTab = type
                                animationProgress = 1.0
                                //MARK: Scrolling to the selected content
                                proxy.scrollTo(type, anchor: .topLeading)
                            }
                        }
                }
            }
            .padding(.vertical, 15)
            .onChange(of: activeTab) { newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newValue.tabID, anchor: .center)
                }
            }
            .checkAnimationEnd(for: animationProgress) {
                //MARK: Resting to default .when the animation was finished
                animationProgress = 0.0
            }
            
        }
        .background{
            Rectangle()
                .fill(Color("Blue"))
                .shadow(color: .blue.opacity(0.2), radius: 5, x: 5, y: 5)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
