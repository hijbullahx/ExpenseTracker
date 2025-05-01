using Microsoft.AspNetCore.Mvc;
using ExpenseTracker.Models;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace ExpenseTracker.Controllers
{
    public class ExpensesController : Controller
    {
        private readonly ExpenseDbContext _context;

        public ExpensesController(ExpenseDbContext context)
        {
            _context = context;
        }

        // GET: Expenses
        public IActionResult Index()
        {
            var expenses = _context.Expenses.ToList();
            return View(expenses);
        }

        // GET: Expenses/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Expenses/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Create(Expense expense)
        {
            if (ModelState.IsValid)
            {
                _context.Add(expense);
                _context.SaveChanges();
                return RedirectToAction(nameof(Index));
            }
            return View(expense);
        }
        public IActionResult Summary()
        {
            var summary = _context.Expenses
                .GroupBy(e => e.Category)
                .Select(g => new { Category = g.Key, Total = g.Sum(e => e.Amount) })
                .ToList();
            return View(summary);
        }
    }
}