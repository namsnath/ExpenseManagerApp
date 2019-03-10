import 'package:flutter/material.dart';

import 'layout.dart';
import 'FABWithIcons.dart';
import 'FABBottomAppBar.dart';

import 'summaryPage.dart';
import 'category.dart';
import 'transactionList.dart';

class MyHomePage extends StatefulWidget {
	MyHomePage({Key key, this.title}) : super(key: key);

	final String title;

	@override
	_MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
	static final tabPage = [
		SummaryPage(title: '',),
		TransactionListPage(title: '',),
//		CategoryPage(title: 'Categories',),
//		TransactionListPage(title: 'Transactions',),
	];

	StatefulWidget _lastSelected = tabPage[0];

	void _selectedTab(int index) {
		setState(() {
			_lastSelected = tabPage[index];
		});
	}

	void _selectedFab(int index) {
		setState(() {
//			_lastSelected = 'FAB: $index';
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(widget.title),
			),
			body: Center(
				child: _lastSelected,
			),
			bottomNavigationBar: FABBottomAppBar(
				centerItemText: '',
				color: Colors.grey,
				selectedColor: Colors.red,
				notchedShape: CircularNotchedRectangle(),
				onTabSelected: _selectedTab,
				items: [
					FABBottomAppBarItem(iconData: Icons.pie_chart, text: 'Summary'),
					FABBottomAppBarItem(iconData: Icons.list, text: 'Transactions'),
//					FABBottomAppBarItem(iconData: Icons.dashboard, text: 'Bottom'),
//					FABBottomAppBarItem(iconData: Icons.info, text: 'Bar'),
				],
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//			floatingActionButton: _buildFab(context),
			floatingActionButton: FloatingActionButton(
				onPressed: null,
				tooltip: 'Increment',
				child: Icon(Icons.add),
				elevation: 2.0,
			),
		);
	}

	Widget _buildFab(BuildContext context) {
		final icons = [ Icons.trending_up, Icons.trending_down ];
		final text = [ 'Income', 'Expense' ];
		return AnchoredOverlay(
			showOverlay: true,
			overlayBuilder: (context, offset) {
				return CenterAbout(
					position: Offset(offset.dx, offset.dy - icons.length * 35.0),
					child: FabWithIcons(
						icons: icons,
						onIconTapped: _selectedFab,
						text: text,
					),
				);
			},
//			child: FloatingActionButton.extended(
			child: FloatingActionButton(
				onPressed: () { },
				tooltip: 'Increment',
				child: Icon(Icons.add),
				elevation: 2.0,
//				label: Text('Expense'),
//				icon: Icon(Icons.add)
			),
		);
	}
}